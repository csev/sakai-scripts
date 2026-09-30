# Building Sakai on macOS 11 Big Sur

These notes are for building Sakai on an older Intel Mac running:

```text
macOS 11.7.10 (Big Sur)
Intel x86_64
Java 17
```

The Sakai build itself is basically fine on this machine, but newer frontend tooling has started shipping binaries built for macOS 12+.

## Build command

My normal build script runs roughly:

```bash
mvn -T 2 -e \
  -Dmaven.test.skip=true \
  -Dsakai.skip.webcomponents.tests=true \
  -Dmaven.tomcat.home=/Users/csev/sakai/scripts/apache-tomcat-9.0.21/ \
  -Dsakai.cleanup=true \
  clean install sakai:deploy
```

Important: `-Dmaven.test.skip=true` does **not** skip the Web Components npm/Playwright tests. Those are controlled separately by:

```bash
-Dsakai.skip.webcomponents.tests=true
```

The relevant `webcomponents/tool/pom.xml` execution is:

```xml
<execution>
    <id>test</id>
    <goals>
        <goal>npm</goal>
    </goals>
    <phase>test</phase>
    <configuration>
        <skip>${sakai.skip.webcomponents.tests}</skip>
        <arguments>run test</arguments>
    </configuration>
</execution>
```

## Problem 1: esbuild 0.27 does not run on Big Sur

The failure looks like:

```text
Error: Command failed: .../node_modules/esbuild/bin/esbuild --version

dyld: Symbol not found: _SecTrustCopyCertificateChain
Referenced from: .../node_modules/esbuild/bin/esbuild
(which was built for Mac OS X 12.0)
Expected in: /System/Library/Frameworks/Security.framework/Versions/A/Security
```

Sakai currently had:

```json
"esbuild": "^0.27.3"
```

For Big Sur, pin it to:

```json
"esbuild": "0.26.0"
```

Then regenerate/update the lockfile using the Node/npm downloaded by Sakai's `frontend-maven-plugin`, not the old system npm.

From:

```bash
cd ~/sakai/scripts/trunk/webcomponents/tool/src/main/frontend
```

run:

```bash
../../../target/node/node \
  ../../../target/node/node_modules/npm/bin/npm-cli.js \
  install
```

Verify:

```bash
./node_modules/esbuild/bin/esbuild --version
```

Expected:

```text
0.26.0
```

Then verify a clean npm install:

```bash
../../../target/node/node \
  ../../../target/node/node_modules/npm/bin/npm-cli.js \
  ci --no-fund
```

This worked on Big Sur.

## Problem 2: Playwright Chromium also requires macOS 12

After fixing esbuild, the build got farther and failed during:

```text
npm run test
```

The failure came from Playwright's downloaded Chromium:

```text
dyld: Symbol not found: _OBJC_CLASS_$_CATapDescription
Referenced from:
~/Library/Caches/ms-playwright/.../chrome-headless-shell
(which was built for Mac OS X 12.0)

Expected in:
/System/Library/Frameworks/CoreAudio.framework/Versions/A/CoreAudio
```

The local workaround is to skip only the Web Components browser tests:

```bash
-Dsakai.skip.webcomponents.tests=true
```

Do **not** use a broad npm skip if the goal is still to install and build the frontend.

## qmv.sh cleanup

To avoid repeating the Maven flags in every branch of the shell script:

```bash
mvn_args=(
    -e
    -Dmaven.test.skip=true
    -Dsakai.skip.webcomponents.tests=true
    -Dmaven.tomcat.home="$tomcatdir"
    -Dsakai.cleanup=true
)

if command -v mvnd >/dev/null 2>&1 && [ "${THREADS:-0}" -gt 1 ]; then
    echo mvnd "${mvn_args[@]}" clean install sakai:deploy
    mvnd "${mvn_args[@]}" clean install sakai:deploy

elif [ "${THREADS:-0}" -gt 1 ]; then
    echo "Compiling with $THREADS threads"
    echo mvn -T "$THREADS" "${mvn_args[@]}" $goals
    mvn -T "$THREADS" "${mvn_args[@]}" $goals

else
    echo "Compiling with 1 thread"
    # Given how we register log4j, even -T 1 messes things up.
    echo mvn "${mvn_args[@]}" $goals
    mvn "${mvn_args[@]}" $goals
fi
```

## Important: use Sakai's npm, not the system npm

This Mac's shell had an old Node/npm:

```text
node v14.17.3
npm 6.14.13
```

That npm cannot handle the workspace dependencies used by Sakai and fails with errors such as:

```text
EUNSUPPORTEDPROTOCOL
Unsupported URL Type "workspace:": workspace:*
```

Sakai's `frontend-maven-plugin` downloads its own frontend toolchain. At the time these notes were written it was:

```text
Node v22.14.0
npm 10.9.2
```

Use that npm for manual frontend diagnosis.

## Useful diagnostics

Check OS:

```bash
sw_vers
```

Check the checked-out code:

```bash
git branch --show-current
git rev-parse --short HEAD
```

Check esbuild declarations:

```bash
cd ~/sakai/scripts/trunk/webcomponents/tool/src/main/frontend
grep -n '"esbuild"' package.json package-lock.json | head -20
```

Check Sakai's downloaded Node/npm:

```bash
../../../target/node/node -v

../../../target/node/node \
  ../../../target/node/node_modules/npm/bin/npm-cli.js \
  --version
```

## Git workflow for the local Big Sur hack

The esbuild pin is a machine compatibility workaround and probably should not accidentally be pushed upstream.

A convenient workflow is:

```bash
git stash push -m "Big Sur esbuild 0.26 workaround"
git switch master
git stash apply
```

Use `apply` rather than `pop` until the patch is confirmed on the target branch.

If `package-lock.json` conflicts because the target branch has moved significantly, reapply the small `package.json` esbuild change manually and regenerate the lockfile with Sakai's bundled npm instead of hand-merging a large lockfile conflict.

## Separate issue seen on newer master

A newer `master` checkout also produced an npm error saying `package.json` and `package-lock.json` were not in sync.

That is a **separate problem** from the Big Sur binary incompatibilities.

Useful distinction:

- `npm ci` complaining that dependencies are missing from the lockfile = repository/lockfile consistency problem.
- `dyld: Symbol not found ... built for Mac OS X 12.0` = Big Sur compatibility problem.

Do not assume fixing the esbuild pin automatically fixes a broken lockfile.

## Short version

For this Intel Big Sur machine:

1. Pin `esbuild` to `0.26.0`.
2. Regenerate the lockfile using Sakai's bundled Node/npm.
3. Confirm `esbuild --version` runs.
4. Add `-Dsakai.skip.webcomponents.tests=true` because current Playwright Chromium requires macOS 12.
5. Run the normal Sakai build.
6. Treat any `npm ci` package/lock mismatch on current master as a separate repository issue.
