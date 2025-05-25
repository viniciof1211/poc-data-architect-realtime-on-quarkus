package com.omura.route;

import javax.enterprise.context.ApplicationScoped;
import org.apache.camel.builder.RouteBuilder;

@ApplicationScoped
public class ClienteRoute extends RouteBuilder {
    @Override
    public void configure() throws Exception {
        from("timer:load-customers?period=60000")
          .to("mongodb:sync?host=mongodb&database=omura&collection=clientes&operation=findAll")
          .marshal().json()
          .log("Fetched clientes: ${body}");
    }
}
