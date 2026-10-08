const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const {after, test} = require("node:test");

const createFunctionsTest = require("firebase-functions-test");

const functionsTest = createFunctionsTest();
const {reportContent} = require("./index");
const wrappedReportContent = functionsTest.wrap(reportContent);

after(() => {
  functionsTest.cleanup();
});

const validData = Object.freeze({
  contentType: "user",
  contentId: "target-user",
  targetUserId: "target-user",
  reason: "Spam",
  details: "Test report",
  metadata: {surface: "security_test"},
  confirmed: true,
  clientRequestId: "security_request_1234",
});

function requestWith(data, uid = "reporter-user") {
  return {
    auth: uid ? {uid, token: {}} : undefined,
    data: {...validData, ...data},
  };
}

async function expectHttpsError(request, expectedCode) {
  await assert.rejects(
      wrappedReportContent(request),
      (error) => {
        assert.equal(error.code, expectedCode);
        return true;
      },
  );
}

test("rejects unauthenticated report attempts", async () => {
  await expectHttpsError(requestWith({}, null), "unauthenticated");
});

test("rejects self-report attempts", async () => {
  await expectHttpsError(
      requestWith({
        contentId: "reporter-user",
        targetUserId: "reporter-user",
      }),
      "invalid-argument",
  );
});

test("rejects unsupported content types", async () => {
  await expectHttpsError(
      requestWith({contentType: "notification"}),
      "invalid-argument",
  );
});

test("rejects overlong report reasons", async () => {
  await expectHttpsError(
      requestWith({reason: "x".repeat(121)}),
      "invalid-argument",
  );
});

test("rejects malformed confirmed request ids", async () => {
  await expectHttpsError(
      requestWith({clientRequestId: "short"}),
      "invalid-argument",
  );
});

test("rejects a user report whose content id is another user", async () => {
  await expectHttpsError(
      requestWith({contentId: "different-user"}),
      "invalid-argument",
  );
});

test("Firestore rules deny client create and delete for reports", () => {
  const rulesPath = path.join(__dirname, "..", "firestore.rules");
  const rules = fs.readFileSync(rulesPath, "utf8");
  const moderationRules = rules.match(
      /match \/moderation_reports\/\{reportId\} \{([\s\S]*?)\n    \}/,
  );

  assert.ok(moderationRules, "moderation_reports rules block must exist");
  assert.match(moderationRules[1], /allow read: if isAdmin\(\);/);
  assert.match(moderationRules[1], /allow create, delete: if false;/);
});
