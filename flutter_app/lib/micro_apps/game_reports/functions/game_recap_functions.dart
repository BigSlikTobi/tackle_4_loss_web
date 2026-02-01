// Definition of the get_game_recap tool for FunctionGemma
// This schema tells the LLM how to call our local function.
// Note: As valid types are not exported, we use a raw JSON schema string
// which can be injected into the system prompt.

const String getGameRecapToolJson = '''
{
  "name": "get_game_recap",
  "description": "Generates a post-game recap for a completed NFL game based on game ID and style.",
  "parameters": {
    "type": "object",
    "properties": {
      "game_id": {
        "type": "string",
        "description": "The unique identifier of the game to recap."
      },
      "focus_team": {
        "type": "string",
        "description": "The name or ID of the team to focus the narrative on (optional).",
        "nullable": true
      },
      "style": {
        "type": "string",
        "description": "The style of the report: casual, detailed, or stats.",
        "enum": ["casual", "detailed", "stats"]
      }
    },
    "required": ["game_id"]
  }
}
''';
