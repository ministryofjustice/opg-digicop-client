<?php

namespace AppBundle\Service\File\Types;

use AppBundle\Service\File\Checker\ClamAVChecker;
use AppBundle\Service\File\Checker\PdfChecker;
use Psr\Log\LoggerInterface;

class Pdf extends UploadableFile
{
    protected $scannerEndpoint = 'scanonly';

    public function __construct(
        ClamAVChecker $virusChecker,
        PdfChecker $fileChecker,
        LoggerInterface $logger
    ) {
        parent::__construct($logger);
        $this->fileCheckers = [$virusChecker, $fileChecker];
    }
}
