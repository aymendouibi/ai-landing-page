<?php

namespace App\Services\AI\Prompts;

class DesignBriefPrompt
{
    /**
     * @param array<string, mixed> $businessAnalysis
     * @param array<string, mixed>|null $recipe
     * @return array<array{role: string, content: string}>
     */
    public static function build(array $businessAnalysis, ?array $recipe = null): array
    {
        $system = <<<PROMPT
You are a principal creative director and design system architect.
Generate a tailored theme configuration for the website based on the business analysis.
Respond with pure JSON only matching this schema:
{
  "theme": {
    "colors": {
      "primary": "#HEX",
      "secondary": "#HEX",
      "accent": "#HEX",
      "background": "#HEX",
      "surface": "#HEX",
      "text": {
        "primary": "#HEX",
        "secondary": "#HEX",
        "inverse": "#HEX"
      }
    },
    "typography": {
      "headingFamily": "Inter | Playfair Display | Plus Jakarta Sans | Poppins | Merriweather",
      "bodyFamily": "Inter | Roboto | Open Sans | Lato",
      "scale": {
        "h1": { "size": "3.5rem", "weight": 700, "lineHeight": 1.1 },
        "h2": { "size": "2.25rem", "weight": 700, "lineHeight": 1.2 },
        "h3": { "size": "1.5rem", "weight": 600, "lineHeight": 1.3 },
        "body": { "size": "1rem", "weight": 400, "lineHeight": 1.6 }
      }
    },
    "spacing": {
      "sectionPadding": { "x": "1.5rem", "y": "5rem" },
      "containerMaxWidth": "1200px",
      "borderRadius": { "small": "0.375rem", "medium": "0.75rem", "large": "1rem", "full": "9999px" }
    }
  }
}
PROMPT;

        $context = "Business Analysis:\n" . json_encode($businessAnalysis, JSON_PRETTY_PRINT);
        if ($recipe) {
            $context .= "\n\nPreferred Design Recipe:\n" . json_encode($recipe, JSON_PRETTY_PRINT);
        }

        return [
            ['role' => 'system', 'content' => $system],
            ['role' => 'user', 'content' => $context],
        ];
    }
}
