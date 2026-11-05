<?php

namespace App\Http\Requests\Websites;

use App\Enums\RevisionSource;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateDocumentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'document' => ['required', 'array'],
            'expected_revision_number' => ['nullable', 'integer', 'min:1'],
            'description' => ['nullable', 'string', 'max:255'],
            'source' => ['nullable', 'string', Rule::enum(RevisionSource::class)],
            'lock_token' => ['nullable', 'string', 'max:100'],
        ];
    }
}

