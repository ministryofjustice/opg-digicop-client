<?php

namespace AppBundle\Twig;

/**
 * Class AssetsExtension.
 */
class AssetsExtension extends \Twig_Extension
{
    /** @var string $tag */
    private $tag;

    /** @var string $rootDir */
    private $rootDir;

    /**
     * @param string $rootDir
     */
    public function __construct($rootDir)
    {
        $this->rootDir = $rootDir;
    }

    /** Get the version name for assets add it to the url to give a versioned url
     * Like assetic except The minification and versioning is done with gulp.
     *
     * @return string
     */
    public function assetUrlFilter($originalUrl)
    {
        return '/assets/' . $this->getTag() . '/' . ltrim($originalUrl, '/');
    }

    /**
     * @return string
     */
    public function getTag()
    {
        if (!$this->tag) {
            // List the files in the web/assets folder
            $assetRoot = $this->rootDir . '/../web/assets';
            if (file_exists($assetRoot)) {
                $assetContents = array_diff(scandir($assetRoot), ['..', '.']);
                rsort($assetContents);
                return array_shift($assetContents);
            } else {
                return $this->tag = 'assets-dir-missing';
            }
        }

        return $this->tag;
    }

    public function getFilters()
    {
        return [
            new \Twig_SimpleFilter('assetUrl', [$this, 'assetUrlFilter']),
            new \Twig_SimpleFilter('debug', function($e) {
                \Doctrine\Common\Util\Debug::dump($e);
            }),
        ];
    }

    public function getName()
    {
        return 'assets_extension';
    }
}
