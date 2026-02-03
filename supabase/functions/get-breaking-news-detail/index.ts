// @ts-nocheck
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { id } = await req.json()

    if (!id) {
      throw new Error('Missing ID parameter')
    }

    const fetchFromTable = async (table: string) => {
      return await supabaseClient
        .schema('content')
        .from(table)
        .select('*')
        .eq('id', id)
        .single()
    }

    let { data, error } = await fetchFromTable('breaking_news')
    if (error) {
      const fallback = await fetchFromTable('news_updates')
      data = fallback.data
      error = fallback.error
    }

    if (error) throw error

    const images = Array.isArray(data.article_images) ? data.article_images[0] : data.article_images
    let imageUrl = data.image_url ?? data.image_file ?? images?.image_url
    if (imageUrl && typeof imageUrl === 'string' && !imageUrl.startsWith('http')) {
      imageUrl = `${Deno.env.get('SUPABASE_URL')}/storage/v1/object/public/content/${imageUrl}`
    }

    const mappedData = {
      id: data.id,
      headline: data.headline,
      created_at: data.created_at ?? data.createdAt ?? null,
      content: data.content ?? null,
      introduction: data.introduction ?? data.introduction_paragraph ?? null,
      source_url: data.source_url ?? data.url ?? null,
      image_url: imageUrl ?? null,
      image_source: images?.source ?? data.image_source ?? null,
      audio_file: data.audio_file ?? data.tts_file ?? data.audioFile ?? null
    }

    return new Response(JSON.stringify(mappedData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
