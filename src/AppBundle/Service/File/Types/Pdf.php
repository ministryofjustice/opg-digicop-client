<?php

namespace AppBundle\Service\File\Types;

use AppBundle\Service\File\Checker\ClamAVChecker;
use AppBundle\Service\File\Checker\PdfChecker;
use Psr\Log\LoggerInterface;

class Pdf extends UploadableFile
{
    protected $scannerEndpoint = 'upload/pdf';

    public function __construct(
        ClamAVChecker $virusChecker,
        PdfChecker $fileChecker,
        LoggerInterface $logger
    ) {
        $this->logger = $logger;
        $this->fileCheckers = [$virusChecker, $fileChecker];
    }
}
