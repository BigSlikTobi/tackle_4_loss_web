import { serve } from "https://deno.land/std@0.224.0/http/server.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
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
            .select(
                "id, headline, created_at, image_url, image_file, x_post, audio_file, tts_file"
            )
            .gt("created_at", twentyFourHoursAgo)
            .order("created_at", { ascending: false })

        if (language_code) {
            query = query.eq("language_code", language_code)
        }

        const { data, error } = await query

        if (error) throw error

        const mappedData = data.map((item: Record<string, unknown>) => {
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

            // Build response object and strip undefined values
            return stripUndefined({
                id: item.id as string,
                headline: item.headline as string,
                created_at: createdAt,
                image_url: imageUrl,
                x_post: xPost,
                audio_file: audioFile,
                createdAt,
                imageUrl,
                xPost,
                audioFile,
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
