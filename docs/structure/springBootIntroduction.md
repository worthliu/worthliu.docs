## 前言

随着动态语言的流行（Ruby、Croovy、Scala、Node.js），Java的开发显得格外的笨重：繁多的配置、低下的开发效率、复杂的部署流程以及第三方技术集成难度大；

Spring Boot，它使用“习惯优于配置”（项目中存在大量的配置此外还内置了一个习惯性的配置，让你无须手动配置）的理念让你的项目快速运行起来。

### Spring Boot核心功能

+ 独立运行的Spring项目，Spring Boot可以以Jar包的形式独立运行；
+ `Spring Boot`可选择内嵌`Tomcat`、`Jetty`或者`Undertow`，无须以war包的形式部署；
+ `Spring Boot`提供了一系列的`starter pom`来简化Maven的依赖加载；
+ `Spring Boot`会根据在类路径中的jar包、类，为jar包里的类自动配置Bean。也可以自定义自动配置；
+ `Spring Boot`提供基于`http`、`ssh`、`telnet`对运行时的项目进行监控；
+ `Spring Boot`是通过条件注解来实现的，这是`Spring4.x`提供的新特性；


### Spring Boot优缺点

优点：
+ 快速构建项目
+ 对主流开发框架的无配置集成；
+ 项目可独立运行，无须外部依赖Servlet容器
+ 提供运行时的应用监控；
+ 极大地提高了开发、部署效率
+ 与云计算的天然集成

缺点：
+ 文档较少且不够深入
+ 需要Spring框架

### Spring Boot快速搭建

+ `http://start.spring.io/`
+ `Spring Boot  CLI`是Spring Boot提供的控制台命令工具
  + `spring init --build=maven --java-version=1.8 --dependencies=web --packaging=jar --boot-version=1.3.8.RELEASE --groupId=com.worth --artifactId=wlspringboot4`
+ `@SpringBootApplication`是Spring Boot项目的核心注解，主要目的是开启自动配置。


### Spring Boot基本配置

```
@SpringBootApplication
public class ControllerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ControllerApplication.class, args);
    }

}
```

SpringBoot无论怎么定制,本质上与上面代码种启动类代码都是一样的!

其中有两个关键点`@SpringBootApplication`和`SpringApplication.run()`;

#### `@SpringBootApplication`

`@SpringBootApplication`本身是一个注解组合体,其由`@SpringBootConfiguration`,`@EnableAutoConfiguration`,`@ComponentScan`组合而成;

+ `@SpringBootConfiguration`,本质上就是`@Configuration`,来源于Spring-content,是基于JavaConfig的配置方式;这里的启动类标注了之后,本身其实也是一个IOC容器的配置类;
+ `@EnableAutoConfiguration`,借助`@Import`的帮助,将所有符合自动配置条件的bean定义加载到IOC容器;
  + 
+ 
