import { serve } from "https://deno.land/std@0.224.0/http/server.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
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

    const { id } = await req.json().catch(() => ({}))

    if (!id) {
      throw new Error("Missing ID parameter")
    }

    const { data, error } = await supabaseClient
      .schema("content")
      .from("news_updates")
      .select("*")
      .eq("id", id)
      .single()

    if (error) throw error

    const imageRaw =
      data.image_url ??
      data.image_file ??
      data.imageUrl ??
      (Array.isArray(data.article_images) ? data.article_images[0]?.image_url : data.article_images?.image_url)
    let imageUrl = imageRaw
    if (imageUrl && !imageUrl.startsWith("http")) {
      imageUrl = `${Deno.env.get("SUPABASE_URL")}/storage/v1/object/public/content/${imageUrl}`
    }

    const createdAt = data.created_at ?? data.createdAt
    const audioFile = data.audio_file ?? data.tts_file ?? data.audioFile
    const introduction =
      data.introduction ??
      data.introduction_paragraph ??
      data.introductionParagraph
    const sourceUrl = data.source_url ?? data.sourceUrl
    const imageSource =
      data.image_source ??
      (Array.isArray(data.article_images) ? data.article_images[0]?.source : data.article_images?.source)

    const mappedData = {
      id: data.id,
      headline: data.headline,
      created_at: createdAt,
      content: data.content,
      introduction,
      source_url: sourceUrl,
      image_url: imageUrl,
      image_source: imageSource,
      audio_file: audioFile,
      createdAt,
      imageUrl,
      audioFile,
      sourceUrl,
      imageSource,
    }

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
