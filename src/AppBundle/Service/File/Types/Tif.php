<?php

namespace AppBundle\Service\File\Types;

use AppBundle\Service\File\Checker\ClamAVChecker;
use AppBundle\Service\File\Checker\TifChecker;
use Psr\Log\LoggerInterface;

class Tif extends UploadableFile
{
    protected $scannerEndpoint = 'upload/tiff/scanonly';

    public function __construct(
        ClamAVChecker $virusChecker,
        TifChecker $fileChecker,
        LoggerInterface $logger
    ) {
        parent::__construct($logger);
        $this->fileCheckers = [$virusChecker, $fileChecker];
    }
}
