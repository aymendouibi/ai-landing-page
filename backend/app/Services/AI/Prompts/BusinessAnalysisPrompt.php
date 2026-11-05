<?php

namespace App\Services\AI\Prompts;

class BusinessAnalysisPrompt
{
    /**
     * @param string $userInput
     * @return array<array{role: string, content: string}>
     */
    public static function build(string $userInput): array
    {
        $system = <<<PROMPT
You are a senior digital product strategist and brand analyst.
Analyze the user's business description and extract key structured information.
Respond with pure JSON only, matching this exact schema:
{
  "business_name": "string",
  "industry": "string",
  "tagline": "string",
  "value_proposition": "string",
  "target_audience": "string",
  "primary_goal": "lead_generation | sales | branding | portfolio | bookings",
  "suggested_tone": "professional | modern | luxurious | friendly | bold | minimal",
  "key_features": ["string", "string", "string"],
  "recommended_pages": ["Home", "About", "Services", "Contact"]
}
PROMPT;

        return [
            ['role' => 'system', 'content' => $system],
            ['role' => 'user', 'content' => "Business description:\n" . $userInput],
        ];
    }
}

