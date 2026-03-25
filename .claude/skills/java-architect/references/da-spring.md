# DA Spring Reference
> Hyperoptic microservice conventions for Spring Boot services.

---

## Project Structure
```
com.hyperoptic.{service-name}/
├── {ServiceName}Application.java
├── common/
├── config/
│   ├── {ServiceName}Config.java
│   └── SecurityConfig.java
├── exception/
│   ├── handler/GlobalExceptionHandler.java
│   └── {ServiceName}Exception.java
├── model/
│   ├── assembler/   # Entity → DTO mapping + HATEOAS links
│   ├── dto/         # RepresentationModel<T> DTOs
│   └── entity/
├── service/
└── rest/controller/
```

---

## Coding Conventions

**Java**
- Indentation: 4 spaces, K&R braces
- Classes: `PascalCase` | Methods/variables: `camelCase` | Constants: `UPPER_SNAKE_CASE`

**YAML**
- Indentation: 2 spaces, `kebab-case` keys

---

## Dependencies
Use Maven with BOMs for version consistency:
```xml
<dependencyManagement>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-dependencies</artifactId>
      <version>2.7.1</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>
```

---

## Version Control (GitHub Flow)
1. Branch from `master`: `feature/CUS-1234-short-description`
2. Commit format: `{JIRA-TICKET}: {imperative subject}` — reads as "Applying this commit will…"
3. PR `feature/... → master` deploys to **Staging**
4. Merge to `master` deploys to **Production**
5. **Only one open PR per repo at a time** (second PR overwrites Staging)

---

## API Response Codes

| Method | Success | Client Errors |
|--------|---------|---------------|
| GET | 200 | 401, 404 |
| POST | 201 | 400, 401, 404 |
| PUT/PATCH | 200 or 204 | 400, 401, 404 |
| DELETE | 204 | 400, 401, 404 |

---

## Security
- Stateless JWT via `oauth2ResourceServer`
- All routes authenticated except `/actuator/**`
- CORS configured via `HyperopticProperties`
- Use roles/authorities for fine-grained access control; never commit secrets

---

## Database (Flyway)
- Naming: `V{major}_{minor}_{patch}__{description}.sql`
- Initial version: `V1_0_0__add_initial_database_schema.sql`
- Breaking changes → bump major version

---

## Configuration
- Defaults in `application.yaml` for local dev
- Override via environment variables in Staging/Production (Spring's externalized config)
- Secrets stored in **AWS Secrets Manager** → surfaced as Kubernetes secrets via `ExternalSecret`
- No secrets in source control

Spring property → env var mapping example:
```
spring.datasource.url  →  SPRING_DATASOURCE_URL
```

---

## DTOs

Standard annotations on every DTO:
```java
@Data @Builder @AllArgsConstructor @NoArgsConstructor
@Accessors(chain = true)
@Relation(collectionRelation = "things")
@JsonIgnoreProperties(ignoreUnknown = true)
public class Thing extends RepresentationModel<Thing> { ... }
```

- Follow [Schema.org](https://schema.org) naming for fields where possible
- Extend `RepresentationModel<T>` for HATEOAS support

---

## Assemblers (Entity → DTO + HATEOAS)
```java
@Component
public class ThingAssembler extends RepresentationModelAssemblerSupport<ThingEntity, Thing> {
    @Override
    public Thing toModel(ThingEntity entity) {
        return mapper.map(entity, Thing.class)
            .add(linkTo(methodOn(ThingController.class).getById(entity.getId())).withSelfRel());
    }
}
```
Always add a self-link via the `getById` endpoint.

---

## Specifications (JPA)
Use `Specification<T>` for any non-trivial GET filter. Always scope to the token's `customerId`:
```java
@Builder
public class ThingSpecification implements Specification<ThingEntity> {
    @NonNull private UserInformation userInfo;
    private Collection<UUID> thingIds;

    @Override
    public Predicate toPredicate(Root<ThingEntity> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
        query.distinct(true);
        List<Predicate> filters = new ArrayList<>();
        // always restrict to token customer
        filters.add(cb.equal(customerJoin.get(CustomerEntity_.identifier), userInfo.getCustomerId()));
        if (CollectionUtils.isNotEmpty(thingIds))
            filters.add(root.get(ThingEntity_.id).in(thingIds));
        return cb.and(filters.toArray(Predicate[]::new));
    }
}
```
Repository must extend `JpaSpecificationExecutor<T>`. Prefer `Collection<T>` for filter params to support multi-select.

---

## Kafka Events
Wrap all payloads in `KafkaMessage`:
```json
{
  "id": "<uuid>",
  "additionalType": "THING_UPDATED",
  "operationType": "UPDATED",
  "timestamp": "2024-11-12T13:47:43.892Z",
  "version": "1.0",
  "value": { }
}
```

**⚠️ Never publish inside `@Transactional`** — use `ApplicationEventPublisher` + `@TransactionalEventListener(phase = AFTER_COMMIT)` to guarantee the DB has committed before the event fires.

---

## Logging
SLF4J via Lombok `@Slf4j`. Always use parameterised logging:
```java
log.info("Updated account for customer [{}]", customerId);  // ✓
log.info("Updated account for customer " + customerId);     // ✗
```

---

## Exception Handling
- Global handler via `@ControllerAdvice` → `GlobalExceptionHandler`
- Custom exceptions extend `RuntimeException`

---

## Stylistic Patterns

**Builder (creation):**
```java
Thing.builder().field(value).build();
```

**Chained setters (updates):**
```java
repository.save(entity.setField(value).setOther(value2));
```

---

## Testing
- Unit: JUnit 5 + Mockito (`@ExtendWith(MockitoExtension.class)`)
- Spring context: `@ExtendWith(SpringExtension.class)`
- Integration: `@SpringBootTest`

---

## Documentation
- `README.md` with setup, usage, contribution guidelines
- Swagger/OpenAPI for API docs
