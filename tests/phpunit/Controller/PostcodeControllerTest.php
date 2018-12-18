<?php

namespace AppBundle\Controller;

class PostcodeControllerTest extends AbstractControllerTestCase
{
    public function testHomePage()
    {
        $this->client->request('GET', '/postcode-lookup');

        $this->assertEquals(302, $this->client->getResponse()->getStatusCode());
    }
}