<?php

namespace App\Exceptions;

use Exception;

class DocumentConflictException extends Exception
{
    public function __construct(string $message = 'The document has been modified by another process. Please refresh and try again.', int $code = 409)
    {
        parent::__construct($message, $code);
    }
}
