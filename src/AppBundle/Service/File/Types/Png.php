<?php

namespace AppBundle\Service\File\Types;

use AppBundle\Service\File\Checker\ClamAVChecker;
use AppBundle\Service\File\Checker\PngChecker;
use Psr\Log\LoggerInterface;

class Png extends UploadableFile
{
    protected $scannerEndpoint = 'scanonly';

    public function __construct(
        ClamAVChecker $virusChecker,
        PngChecker $fileChecker,
        LoggerInterface $logger
    ) {
        parent::__construct($logger);
        $this->fileCheckers = [$virusChecker, $fileChecker];
    }
}
