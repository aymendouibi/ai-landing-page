<?php

namespace App\Http\Requests\Websites;

use Illuminate\Foundation\Http\FormRequest;

class UpdateWebsiteRequest extends FormRequest
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
        $websiteId = $this->route('website')?->id ?? $this->route('website');

        return [
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'slug' => ['sometimes', 'required', 'string', 'max:100', 'regex:/^[a-z0-9\-]+$/'],
            'subdomain' => ['nullable', 'string', 'max:63', 'regex:/^[a-z0-9\-]+$/', "unique:websites,subdomain,{$websiteId}"],
        ];
    }
}
