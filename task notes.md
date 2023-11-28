# CSC343-A3

- Each session has at least one recording engineer, and at most 3 -> to check for other approaches

    ...ANSWER...

- One or more people can play on a recording session. Or one or more bands can play on a session. Or both. Whatever the case, there must be at least one person playing on a session. -> check for possible approaches

    ...ANSWER...

- engineer_id is primary key in Engineers


- Create different relation for Engineers+Session, where primary key is (Engineer_id, Session_id)


- Create different relation for Engineers+Session, where primary key is (Engineer_id, certificate_id)


- Manages relation stores history of managerXstudio


- Trigger for updating og_manager_id in studio with id=x when a new row is added to the Manages where studio_id=x


- Check for satisfying these requirements:

    1. Avoid redundancy.
    2. Avoid designing your schema in such a way that there are attributes that can be null.
    3. If a constraint given above in the domain description can be expressed without assertions or triggers, it should be enforced by your schema, unless you can articulate a good reason not to do so.
    4. There may be additional constraints that make sense but were not specified in the domain description. You get to decide on whether to enforce any of these in your DDL.
