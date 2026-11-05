<?php

namespace App\Services\AI\Prompts;

use Exception;

class PromptHelper
{
    /**
     * Clean and parse JSON from an AI response.
     * Safely strips markdown code blocks if the model wrapped the JSON.
     *
     * @param string $rawContent
     * @return array<string, mixed>
     * @throws Exception
     */
    public static function extractJson(string $rawContent): array
    {
        $cleaned = trim($rawContent);

        // Strip ```json or ``` blocks
        if (preg_match('/```(?:json)?\s*([\s\S]*?)\s*```/i', $cleaned, $matches)) {
            $cleaned = trim($matches[1]);
        }

        // If content starts before the first '{' or ends after '}', find boundaries
        $startPos = strpos($cleaned, '{');
        $endPos = strrpos($cleaned, '}');

        if ($startPos !== false && $endPos !== false && $endPos > $startPos) {
            $cleaned = substr($cleaned, $startPos, $endPos - $startPos + 1);
        }

        $decoded = json_decode($cleaned, true);

        if (!is_array($decoded)) {
            throw new Exception("Failed to decode JSON from AI response: " . json_last_error_msg() . "\nRaw: " . substr($rawContent, 0, 500));
        }

        return $decoded;
    }
}

