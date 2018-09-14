<?php

namespace AppBundle\Controller;

use AppBundle\Entity\Document;
use AppBundle\Entity\Order;
use AppBundle\Form\DocumentForm;
use AppBundle\Service\DocumentService;
use AppBundle\Service\File\Checker\Exception\RiskyFileException;
use AppBundle\Service\File\Checker\Exception\VirusFoundException;
use AppBundle\Service\File\FileUploader;
use AppBundle\Service\File\Types\UploadableFileInterface;
use Doctrine\ORM\EntityManager;
use Psr\Log\LoggerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\Form\FormError;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\File\UploadedFile;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class DocumentController extends Controller
{
    /**
     * @var EntityManager
     */
    private $em;


    /**
     * @var DocumentService
     */
    private $documentService;

    /**
     * @var LoggerInterface
     */
    private $logger;

    /**
     * UserController constructor.
     * @param EntityManager $em
     */
    public function __construct(EntityManager $em, DocumentService $documentService, LoggerInterface $logger)
    {
        $this->em = $em;
        $this->documentService = $documentService;
        $this->logger = $logger;
    }

    /**
     * @Route("/order/{orderId}/document/{docType}/add", name="document-add")
     */
    public function addAction(Request $request, $orderId, $docType)
    {
        $order = $this->em->getRepository(Order::class)->find($orderId);
        if (!$order) {
            throw new \RuntimeException("Order not existing");
        }

        $document = new Document($order, $docType);
        $form = $this->createForm(DocumentForm::class, $document);

        if ($request->get('error') == 'tooBig') {
            $message = $this->get('translator')->trans('document.file.errors.maxSizeMessage', [], 'validators');
            $form->get('file')->addError(new FormError($message));
        }
        $form->handleRequest($request);
        if ($form->isSubmitted() && $form->isValid()) {
            $fileUploader = $this->container->get('file_uploader'); /* @var $fileUploader FileUploader */
            /* @var $uploadedFile UploadedFile */
            $uploadedFile = $document->getFile();
            /** @var UploadableFileInterface $fileObject */
            $fileObject = $this->get('file_checker_factory')->factory($uploadedFile);
            try {
                $fileObject->checkFile();
                if ($fileObject->isSafe()) {
                    $document = $fileUploader->uploadFile(
                        $order,
                        $document,
                        file_get_contents($uploadedFile->getPathName()),
                        $uploadedFile->getClientOriginalName()
                    );
                    $request->getSession()->getFlashBag()->add('notice', 'File uploaded');

                    $fileName = $request->files->get('document_form')['file']->getClientOriginalName();
                    $document->setFilename($fileName);

                    $this->em->persist($document);
                    $this->em->flush($document);
                } else {
                    $request->getSession()->getFlashBag()->add('notice', 'File could not be uploaded');
                }

                return $this->redirectToRoute('order-summary', ['orderId' => $order->getId()]);
            } catch (\Exception $e) {

                $errorToErrorTranslationKey = [
                    RiskyFileException::class => 'risky',
                    VirusFoundException::class => 'virusFound',
                ];
                $errorClass = get_class($e);
                if (isset($errorToErrorTranslationKey[$errorClass])) {
                    $errorKey = $errorToErrorTranslationKey[$errorClass];
                } else {
                    $errorKey = 'generic';
                }
                $message = $this->get('translator')->trans("document.file.errors.{$errorKey}", [
                    '%techDetails%' => $this->getParameter('kernel.debug') ? $e->getMessage() : $request->headers->get('x-request-id'),
                ], 'validators');
                $form->get('file')->addError(new FormError($message));
                $this->get('logger')->error($e->getMessage()); //fully log exceptions
            }
        }

        return $this->render('AppBundle:Document:add.html.twig', [
            'order' => $order,
            'docType' => $docType,
            'form' => $form->createView()
        ]);
    }

    /**
     * @Route("/order/{orderId}/document/{id}/remove", name="document-remove")
     */
    public function removeAction(Request $request, $orderId, $id)
    {
        try {
            $this->documentService->deleteDocumentById($id);
        } catch ( \Exception $e) {
            $this->get('logger')->error($e->getMessage());
            $this->addFlash('error', 'Document could not be removed.');
        }

        return $this->redirectToRoute('order-summary', ['orderId' => $orderId]);
    }


}
