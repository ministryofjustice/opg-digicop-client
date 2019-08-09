<?php

namespace App\Behat;

use Behat\Behat\Context\Context;
use Behat\MinkExtension\Context\MinkContext;

/**
 * Behat context class.
 */
class FeatureContext extends MinkContext implements Context
{
    use RegionLinksTrait;
    use FormTrait;
    use DebugTrait;
    use SiriusTrait;
    use NotifyTrait;

    /**
     * @Then /^the (?P<name>(.*)) response header should be (?P<value>(.*))$/
     */
    public function theHeaderContains($name, $value)
    {
        $this->assertSession()->responseHeaderContains($name, $value);
    }

    /**
     * @Then the current versions should be shown
     */
    public function theCurrentVersionsAreShown()
    {
        $this->assertResponseContains(json_encode([
            'application' => getenv("APP_VERSION"),
            'web' => getenv("WEB_VERSION"),
            'infrastructure' => getenv("INFRA_VERSION")
        ]));
    }

    /**
     * @Given I log in as :user with password :password
     */
    public function iLogInAs($user, $password)
    {
        $this->visit("/login");
        $this->fillField('login_username', $user);
        $this->fillField('login_password', $password);
        $this->pressButton('login_submit');
    }

    /**
     * @Given /^I am authenticated with username "([^"]*)" password "([^"]*)"$/
     */
    public function iAmAuthenticatedWith($user, $password)
    {
        $this->getSession()->setBasicAuth($user, $password);
    }

    /**
     * @Then /^the order should be (?P<shouldBe>(servable|unservable))$/
     */
    public function theOrderIsOrNotServable($shouldBe)
    {
        $this->assertResponseStatus(200);

        if ($shouldBe == 'servable') {
            $this->assertSession()->elementExists('css', '#serve_order_button');
        }

        if ($shouldBe == 'unservable') {
            $this->assertSession()->elementNotExists('css', '#serve_order_button');
        }
    }

    /**
     * @Then :service status should be :status
     */
    public function statusShouldBe($service, $status)
    {
        $this->assertResponseContains("\"$service\":$status");
    }

    /**
     * @Then :service status should not be :status
     */
    public function statusShouldNotBe($service, $status)
    {
        $this->assertResponseNotContains("\"$service\":$status");
        $this->assertResponseNotContains("\"$service\":\"$status\"");
    }

    /**
     * @Then auto complete should be disabled
     */
    public function autoCompleteDisabled()
    {
        $page = $this->getSession()->getPage()->find('css', '#login')->getAttribute('autocomplete');
        $this->assertResponseContains('off');
    }
}
