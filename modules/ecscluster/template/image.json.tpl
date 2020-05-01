[
  {
    "name": "firstapp",
    "image": "${image1}",
    "essential": true,
    "cpu": ${cpu},
     links": [
      "${image2}"
    ],
    "memory": ${memory},
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/myapp",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "portMappings": [
      {
        "containerPort": ${appport},
        "hostPort": ${appport}
      }
    ]
  },
   {
    "name": "secondapp",
    "image": "${image2}",
    "essential": true,
    "cpu": ${cpu},
    "memory": ${memory},
    "environment": [
            {"name": "MYSQL_ROOT_PASSWORD", "value": "password"}
        ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/myapp",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    }
  }
]