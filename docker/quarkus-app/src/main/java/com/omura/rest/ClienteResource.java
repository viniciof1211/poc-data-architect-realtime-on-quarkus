package com.omura.rest;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import com.mongodb.client.MongoClient;
import org.bson.Document;
import java.util.List;

@Path("/clientes")
@Produces(MediaType.APPLICATION_JSON)
public class ClienteResource {

    @Inject
    MongoClient mongoClient;

    @GET
    public List<Document> list() {
        return mongoClient.getDatabase("omura")
                          .getCollection("clientes")
                          .find()
                          .into(new java.util.ArrayList<>());
    }
}
