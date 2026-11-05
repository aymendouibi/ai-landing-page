<?php

namespace App\Exceptions;

use Exception;

class InvalidDocumentException extends Exception
{
    /** @var array<string> */
    protected array $errors;

    /**
     * @param array<string> $errors
     */
    public function __construct(array $errors, string $message = 'The website document is invalid.', int $code = 422)
    {
        parent::__construct($message, $code);
        $this->errors = $errors;
    }

    /**
     * @return array<string>
     */
    public function getErrors(): array
    {
        return $this->errors;
    }
}
