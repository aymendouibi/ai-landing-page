<?php

namespace Tests\Unit;

use App\Exceptions\InvalidDocumentException;
use App\Services\Documents\DefaultDocumentFactory;
use App\Services\Documents\DocumentValidator;
use PHPUnit\Framework\TestCase;

class DocumentValidatorTest extends TestCase
{
    protected DocumentValidator $validator;

    protected function setUp(): void
    {
        parent::setUp();
        $this->validator = new DocumentValidator();
    }

    public function test_default_factory_document_is_valid(): void
    {
        $doc = DefaultDocumentFactory::createDefault('Test');
        $this->validator->validate($doc);
        $this->assertTrue(true); // Reached without exception
    }

    public function test_missing_schema_version_throws_exception(): void
    {
        $doc = DefaultDocumentFactory::createDefault('Test');
        unset($doc['schema_version']);

        $this->expectException(InvalidDocumentException::class);
        $this->validator->validate($doc);
    }

    public function test_missing_site_name_throws_exception(): void
    {
        $doc = DefaultDocumentFactory::createDefault('Test');
        $doc['site']['name'] = '';

        $this->expectException(InvalidDocumentException::class);
        $this->validator->validate($doc);
    }

    public function test_empty_pages_array_throws_exception(): void
    {
        $doc = DefaultDocumentFactory::createDefault('Test');
        $doc['pages'] = [];

        $this->expectException(InvalidDocumentException::class);
        $this->validator->validate($doc);
    }

    public function test_duplicate_section_ids_throw_exception(): void
    {
        $doc = DefaultDocumentFactory::createDefault('Test');
        $doc['pages'][0]['sections'][1]['id'] = $doc['pages'][0]['sections'][0]['id'];

        $this->expectException(InvalidDocumentException::class);
        $this->validator->validate($doc);
    }

    public function test_unsupported_component_throws_exception(): void
    {
        $doc = DefaultDocumentFactory::createDefault('Test');
        $doc['pages'][0]['sections'][0]['component'] = 'invalid_arbitrary_component';

        $this->expectException(InvalidDocumentException::class);
        $this->validator->validate($doc);
    }

    public function test_duplicate_page_slugs_throw_exception(): void
    {
        $doc = DefaultDocumentFactory::createDefault('Test');
        // Add a second page with same slug '/'
        $doc['pages'][] = [
            'id' => 'page_about',
            'slug' => '/', // Duplicate
            'title' => 'About',
            'sections' => [],
        ];

        $this->expectException(InvalidDocumentException::class);
        $this->validator->validate($doc);
    }
}
