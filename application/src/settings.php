<?php
return [
    'settings' => ($_ENV['PHP_ENV'] ?? 'development') === 'development'
      ? [
            'displayErrorDetails' => true, // set to false in production
            'addContentLengthHeader' => false, // Allow the web server to send the content-length header

            // Renderer settings
            'renderer' => [
                'template_path' => __DIR__ . '/../templates/',
            ],

            // Monolog settings
            'logger' => [
                'name' => 'slim-app',
                'path' => 'php://stdout',
                'level' => \Monolog\Logger::DEBUG,
            ],
        ]

      : [ // As production
            'displayErrorDetails' => false, // set to false in production
            'addContentLengthHeader' => false, // Allow the web server to send the content-length header

            // Renderer settings
            'renderer' => [
                'template_path' => __DIR__ . '/../templates/',
            ],

            // Monolog settings
            'logger' => [
                'name' => 'slim-app',
                'path' => 'php://stdout',
                'level' => \Monolog\Logger::INFO,
            ],
        ]
];
