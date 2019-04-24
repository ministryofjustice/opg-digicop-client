<?php

namespace AppBundle\Service\File\Types;

interface UploadableFileInterface
{
    public function checkFile();

    public function callFileCheckers();

    public function getFileCheckers();
}
