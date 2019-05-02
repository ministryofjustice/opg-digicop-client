<?php


namespace AppBundle\Controller;

use AppBundle\Service\ReportService;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\File\File;
use Symfony\Component\Routing\Annotation\Route;

/**
 * @Route("/report")
 */
class ReportController extends Controller
{
    /**
     * @var ReportService
     */
    private $reportService;

    /**
     *
     * @param ReportService $reportService
     */
    public function __construct(ReportService $reportService)
    {
        $this->reportService = $reportService;
    }

    /**
     * @Route("", name="report")
     */
    public function reportAction() {
        return $this->render('AppBundle:Report:report.html.twig');
    }

    /**
     * @Route("/download", name="download-report")
     */
    public function downloadReportAction() {

        $this->reportService->generateCsv();

        $csv = new File('/tmp/orders.csv');

        return $this->file($csv);
    }

    /**
     * @Route("/cases", name="cases")
     */
    public function casesAction() {
        return $this->render('AppBundle:Report:case-report.html.twig');
    }

    /**
     * @Route("/download-cases", name="download-report-cases")
     */
    public function downloadCasesReportAction() {

        $this->reportService->getCasesBeforeGoLive();

        $csv = new File('/tmp/cases.csv');

        return $this->file($csv);
    }
}