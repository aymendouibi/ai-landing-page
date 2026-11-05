<?php

namespace App\Http\Requests\Websites;

use Illuminate\Foundation\Http\FormRequest;

class StoreWebsiteRequest extends FormRequest
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
            'project_id' => ['required', 'uuid', 'exists:projects,id'],
            'name' => ['required', 'string', 'max:255'],
            'slug' => ['nullable', 'string', 'max:100', 'regex:/^[a-z0-9\-]+$/'],
            'subdomain' => ['nullable', 'string', 'max:63', 'unique:websites,subdomain', 'regex:/^[a-z0-9\-]+$/'],
            'template_id' => ['nullable', 'uuid', 'exists:templates,id'],
            'document' => ['nullable', 'array'],
        ];
    }
}
