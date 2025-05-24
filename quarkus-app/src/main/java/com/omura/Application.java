package com.omura;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;

import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;
import io.smallrye.reactive.messaging.kafka.KafkaRecord;


@Path("/")
public class Application {

    @Channel("orders-out")
    Emitter<String> emitter;

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        emitter.send(KafkaRecord.of("orders", "New order event at " + System.currentTimeMillis()));
        return "OMURA Data Architect POC is up! Hello World from Vinicio's World! ";
    }
}