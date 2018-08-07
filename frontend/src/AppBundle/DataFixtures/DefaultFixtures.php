<?php
namespace AppBundle\DataFixtures;

use AppBundle\Entity\User;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Common\Persistence\ObjectManager;

class DefaultFixtures extends Fixture
{
    public function load(ObjectManager $manager)
    {
        $repo = $manager->getRepository(User::class);
        $users = array_filter(explode("\n", getenv('DC_FIXURES_USERS')));
        foreach($users as $userStr) {
            parse_str($userStr, $user);
            if (!empty($user['email']) && !$repo->findOneBy(['email'=>$user['email']])) {
                $u = new User($user['email']);
                $u->setPassword($user['password']);
                $manager->persist($u);
                echo "Added {$user['email']}\n";
            }
        }
        $manager->flush();
    }
}