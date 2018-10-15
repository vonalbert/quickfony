<?php

namespace App\Menu;

use Knp\Menu\FactoryInterface;
use Symfony\Component\Security\Core\Authorization\AuthorizationCheckerInterface;

class MainMenuBuilder
{
    /** @var FactoryInterface */
    private $factory;

    /** @var AuthorizationCheckerInterface */
    private $authorizationChecker;

    public function __construct(FactoryInterface $factory, AuthorizationCheckerInterface $authorizationChecker)
    {
        $this->factory = $factory;
        $this->authorizationChecker = $authorizationChecker;
    }

    public function createMenu(array $options)
    {
        $menu = $this->factory->createItem('root', $options);


        if ($this->authorizationChecker->isGranted('ROLE_ADMIN')) {
            $menu->addChild('Admin', ['uri' => '#']);
        }

        if ($this->authorizationChecker->isGranted('ROLE_USER')) {
            $menu->addChild('Logout', ['route' => 'logout']);
        } else {
            $menu->addChild('Register', ['uri' => '#']);
            $menu->addChild('Login', ['route' => 'login'])->setLinkAttribute('data-login', '');
        }

        return $menu;
    }
}
