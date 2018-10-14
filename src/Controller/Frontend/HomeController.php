<?php

namespace App\Controller\Frontend;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\Routing\Annotation\Route;

/**
 * @author Alberto Avon<alberto.avon@gmail.com>
 */
class HomeController extends Controller
{
    /**
     * @Route("", name="site_home")
     */
    public function __invoke()
    {
        return $this->render('frontend/home/homepage.html.twig');
    }
}
