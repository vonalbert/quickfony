<?php

namespace App\Controller\Frontend;

use App\Form\LoginType;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\Form\FormError;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Security\Http\Authentication\AuthenticationUtils;
use Symfony\Component\Translation\TranslatorInterface;

class SecurityController extends Controller
{
    /**
     * @Route("/login", name="login")
     */
    public function login(Request $request, AuthenticationUtils $authenticationUtils, TranslatorInterface $translator)
    {
        $form = $this->createForm(LoginType::class, [
            '_username' => $authenticationUtils->getLastUsername(),
        ]);

        if ($error = $authenticationUtils->getLastAuthenticationError()) {
            $form->addError(new FormError(
                $translator->trans($error->getMessageKey(), $error->getMessageData(), 'security')
            ));
        }

        $template = $request->isXmlHttpRequest() ?
            'frontend/security/login_modal.html.twig':
            'frontend/security/login.html.twig';

        return $this->render($template, [
            'form' => $form->createView(),
        ]);
    }

    /**
     * @Route("/logout", name="logout")
     */
    public function logout()
    {
        throw new \RuntimeException('Security misconfiguration: logout controller should not be executed');
    }
}
