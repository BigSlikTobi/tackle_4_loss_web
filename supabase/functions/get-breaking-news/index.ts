import { serve } from "https://deno.land/std@0.224.0/http/server.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
}

interface PlayerData {
    player_id?: string
    [key: string]: unknown
}

// Utility to strip undefined values from an object
function stripUndefined<T extends Record<string, unknown>>(obj: T): Partial<T> {
    return Object.fromEntries(
        Object.entries(obj).filter(([, v]) => v !== undefined)
    ) as Partial<T>
}

serve(async (req) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders })
    }

    try {
        const authHeader = req.headers.get("Authorization") ?? ""
        const supabaseClient = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_ANON_KEY") ?? "",
            {
                global: authHeader
                    ? { headers: { Authorization: authHeader } }
                    : {},
            },
        )

        const { language_code } = await req.json().catch(() => ({}))

        const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()

        let query = supabaseClient
            .schema("content")
            .from("news_updates")
            .select("*")
            .gt("created_at", twentyFourHoursAgo)
            .order("created_at", { ascending: false })

        if (language_code) {
            query = query.eq("language_code", language_code)
        }

        const { data, error } = await query

        if (error) throw error

        // --- Filter out older stories from the same story group ---
        // Only show the latest story per group; older related stories
        // are accessible via the detail screen's "Related Stories" section.
        const articleIds = data.map((item: Record<string, unknown>) => item.id as string)

        let filteredData = data as Record<string, unknown>[]
        if (articleIds.length > 0) {
            const { data: groupData } = await supabaseClient
                .from("news_update_story_groups")
                .select("news_update_id, group_id")
                .in("news_update_id", articleIds)

            if (groupData && groupData.length > 0) {
                // Build a map: group_id -> list of news_update_ids in this batch
                const groupMap = new Map<string, string[]>()
                for (const row of groupData) {
                    const existing = groupMap.get(row.group_id) ?? []
                    existing.push(row.news_update_id)
                    groupMap.set(row.group_id, existing)
                }

                // For each group, find the newest article (first in our desc-sorted list)
                // and mark the rest for removal
                const idsToRemove = new Set<string>()

                for (const [, memberIds] of groupMap) {
                    if (memberIds.length <= 1) continue
                    // data is already sorted desc by created_at, so first match = newest
                    let foundNewest = false
                    for (const item of data as Record<string, unknown>[]) {
                        if (memberIds.includes(item.id as string)) {
                            if (!foundNewest) {
                                foundNewest = true // keep this one
                            } else {
                                idsToRemove.add(item.id as string)
                            }
                        }
                    }
                }

                filteredData = data.filter(
                    (item: Record<string, unknown>) => !idsToRemove.has(item.id as string)
                )
            }
        }

        // Extract all player IDs to fetch headshots in one go
        const playerIds = new Set<string>()
        filteredData.forEach((item: Record<string, unknown>) => {
            const players = item.players as PlayerData[] | undefined
            if (players && Array.isArray(players)) {
                players.forEach((p: PlayerData) => {
                    if (p.player_id) playerIds.add(p.player_id)
                })
            }
        })

        // Fetch player details (headshot) from public.players
        const playersMap = new Map<string, { headshot?: string }>()
        if (playerIds.size > 0) {
            const { data: playersData, error: playersError } = await supabaseClient
                .from("players")
                .select("player_id, headshot")
                .in("player_id", Array.from(playerIds))

            if (!playersError && playersData) {
                playersData.forEach((p: { player_id: string; headshot?: string }) => 
                    playersMap.set(p.player_id, p)
                )
            }
        }

        const mappedData = filteredData.map((item: Record<string, unknown>) => {
            const imageRaw =
                (item.image_url as string | undefined) ??
                (item.image_file as string | undefined) ??
                (item.imageUrl as string | undefined)
            let imageUrl = imageRaw
            if (imageUrl && !imageUrl.startsWith("http")) {
                imageUrl = `${Deno.env.get("SUPABASE_URL")}/storage/v1/object/public/content/${imageUrl}`
            }

            const createdAt =
                (item.created_at as string | undefined) ??
                (item.createdAt as string | undefined)
            const audioFile =
                (item.audio_file as string | undefined) ??
                (item.tts_file as string | undefined) ??
                (item.audioFile as string | undefined)
            const xPost =
                (item.x_post as string | undefined) ??
                (item.xPost as string | undefined)

            // Enrich players with headshot_url
            const playersArray = Array.isArray(item.players) ? item.players as PlayerData[] : []
            const enrichedPlayers = playersArray.map((p: PlayerData) => {
                const details = playersMap.get(p.player_id ?? "")
                return {
                    ...p,
                    headshot_url: details?.headshot,
                }
            })

            // Build response object and strip undefined values
            return stripUndefined({
                id: item.id as string,
                headline: item.headline as string,
                status: item.status as string | undefined,
                created_at: createdAt,
                image_url: imageUrl,
                x_post: xPost,
                audio_file: audioFile,
                createdAt,
                imageUrl,
                xPost,
                audioFile,
                subHeader:
                    (item.sub_header as string | undefined) ??
                    (item.subHeader as string | undefined),
                introductionParagraph:
                    (item.introduction_paragraph as string | undefined) ??
                    (item.introductionParagraph as string | undefined) ??
                    (item.introduction as string | undefined),
                content: item.content as string | undefined,
                teams: Array.isArray(item.teams) ? item.teams : undefined,
                players: enrichedPlayers.length > 0 ? enrichedPlayers : undefined,
                url: item.url as string | undefined,
            })
        })

        return new Response(JSON.stringify(mappedData), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 200,
        })
    } catch (error) {
        const message = error instanceof Error 
            ? error.message 
            : (error as { message?: string })?.message ?? JSON.stringify(error)
        return new Response(JSON.stringify({ error: message }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 400,
        })
    }
})
