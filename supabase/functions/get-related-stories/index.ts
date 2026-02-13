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

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get("Authorization") ?? ""
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: authHeader ? { headers: { Authorization: authHeader } } : {},
      },
    )

    const { news_update_id, language_code } = await req.json().catch(() => ({}))

    if (!news_update_id) {
      throw new Error("Missing news_update_id parameter")
    }

    // Step 1: Find group_ids for this article via the view
    const { data: myGroups, error: myGroupsError } = await supabaseClient
      .from("news_update_story_groups")
      .select("group_id")
      .eq("news_update_id", news_update_id)

    if (myGroupsError) throw myGroupsError

    if (!myGroups || myGroups.length === 0) {
      return new Response(JSON.stringify([]), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      })
    }

    const groupIds = [...new Set(myGroups.map(
      (r: { group_id: string }) => r.group_id
    ))]

    // Step 2: Find all other news_update_ids in those groups
    let relatedQuery = supabaseClient
      .from("news_update_story_groups")
      .select("news_update_id, url, language_code")
      .in("group_id", groupIds)
      .neq("news_update_id", news_update_id)

    if (language_code) {
      relatedQuery = relatedQuery.eq("language_code", language_code)
    }

    const { data: relatedRows, error: relatedError } = await relatedQuery

    if (relatedError) throw relatedError

    if (!relatedRows || relatedRows.length === 0) {
      return new Response(JSON.stringify([]), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      })
    }

    // Deduplicate news_update_ids
    const relatedIds = [...new Set(
      relatedRows.map((r: { news_update_id: string }) => r.news_update_id)
    )]

    // Step 3: Fetch full article data for related stories
    const { data: relatedArticles, error: articlesError } = await supabaseClient
      .schema("content")
      .from("news_updates")
      .select("*")
      .in("id", relatedIds)
      .order("created_at", { ascending: false })

    if (articlesError) throw articlesError

    // Step 5: Normalize and return related stories
    const mappedData = (relatedArticles ?? []).map(
      (item: Record<string, unknown>) => {
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

        return stripUndefined({
          id: item.id as string,
          headline: item.headline as string,
          status: item.status as string | undefined,
          created_at: createdAt,
          image_url: imageUrl,
          createdAt,
          imageUrl,
          subHeader:
            (item.sub_header as string | undefined) ??
            (item.subHeader as string | undefined),
          introductionParagraph:
            (item.introduction_paragraph as string | undefined) ??
            (item.introductionParagraph as string | undefined) ??
            (item.introduction as string | undefined),
          teams: Array.isArray(item.teams) ? item.teams : undefined,
          source_url:
            (item.source_url as string | undefined) ??
            (item.sourceUrl as string | undefined),
          sourceUrl:
            (item.source_url as string | undefined) ??
            (item.sourceUrl as string | undefined),
        })
      }
    )

    return new Response(JSON.stringify(mappedData), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    })
  } catch (error) {
    const message =
      error instanceof Error
        ? error.message
        : (error as { message?: string })?.message ?? JSON.stringify(error)
    return new Response(JSON.stringify({ error: message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    })
  }
})
