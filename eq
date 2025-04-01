[33mcommit d9949e521577ff28da0a96694b6a0addc338c4d7[m[33m ([m[1;36mHEAD -> [m[1;32mmain[m[33m)[m
Merge: 05c5186f 9391c0b0
Author: Karthik babu Manam <karthikmanam@gmail.com>
Date:   Wed Mar 5 13:01:24 2025 +0530

    Merge branch 'main' of github.com:karthikmanam/kyverno-website

[33mcommit 05c5186f0c2bfeac47963389cb525f22fc090260[m
Merge: e0c9e024 1a8d899a
Author: Karthik babu Manam <karthikmanam@gmail.com>
Date:   Wed Mar 5 13:00:08 2025 +0530

    Merge branch 'main' of github.com:karthikmanam/kyverno-website
    
    Signed-off-by: Karthik babu Manam <karthikmanam@gmail.com>

[33mcommit 9391c0b0f1a8cfb54ed4bd415baa520e8e7fd282[m[33m ([m[1;31morigin/main[m[33m, [m[1;31morigin/HEAD[m[33m)[m
Merge: e0c9e024 1a8d899a
Author: Karthik babu Manam <karthikmanam@gmail.com>
Date:   Wed Mar 5 13:00:08 2025 +0530

    Merge branch 'main' of github.com:karthikmanam/kyverno-website

[33mcommit e0c9e024f2c23c6b06c214f0e6ddc219e7c1511b[m
Author: Karthik babu Manam <karthikmanam@gmail.com>
Date:   Wed Mar 5 12:55:19 2025 +0530

    Updating README with instructions for Windows users
    
    Signed-off-by: Karthik babu Manam <karthikmanam@gmail.com>

[33mcommit 1a8d899ababdf0d9b0af075574e036e1df7fbdd2[m
Author: Karthik babu Manam <karthikmanam@gmail.com>
Date:   Wed Mar 5 12:55:19 2025 +0530

    Updating README with instructions for Windows users

[33mcommit 4684c74306aa6e27978849c8abb7ec981a14049b[m
Author: Julien CANON <70962713+juliencanon@users.noreply.github.com>
Date:   Thu Feb 27 07:34:15 2025 +0100

    fix: typo correction in variables.md (#1480)
    
    fix: fix typo in variables.md
    
    Signed-off-by: juliencanon <70962713+juliencanon@users.noreply.github.com>

[33mcommit eb7ff74fb618d2aa3f9a6075b8c99b7261e701ea[m
Author: Ujjwal Sharma <68021601+Darkhood148@users.noreply.github.com>
Date:   Mon Feb 24 18:59:15 2025 +0530

    Adds Kyverno Info Metric page (#1477)
    
    Signed-off-by: Darkhood148 <ujjwal.sharma9999999@gmail.com>

[33mcommit 29be8146c6a58f4ae079d6ef1514ba87aadae82d[m
Author: Ravish Rathod <ravish.rathod@infosys.com>
Date:   Wed Feb 19 12:27:23 2025 +0530

    docs: Corrected spell check for Deployment (#1476)
    
    Corrected spell for Deployment
    
    Signed-off-by: Ravish Rathod <ravish.rathod@infosys.com>

[33mcommit 2502b203101dfe6759298009ff883090b40a954b[m
Author: François Duthilleul <francoisduthilleul@gmail.com>
Date:   Fri Feb 7 07:55:06 2025 +0100

    Update cleanup-ttl-controller-deleted-objects.md (#1469)
    
    In the Kyverno Documentation left menu, there is no way to distinguish the "Cleanup Controller Deleted Objects" from the "Cleanup TTL Controller Deleted Objects" as both are described as "Cleanup Controller Deleted Objects". This change would reflect in the left menu what is specific to the TTL controller.
    
    Signed-off-by: François Duthilleul <francoisduthilleul@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 21b0bd2675a44fd71ab10399b78e9c865e1566e3[m
Author: François Duthilleul <francoisduthilleul@gmail.com>
Date:   Fri Feb 7 07:54:44 2025 +0100

    Update cleanup-ttl-controller-errors.md (#1470)
    
    In the Kyverno Documentation left menu, there is no way to distinguish the "Cleanup Controller Errors Count" from the "Cleanup TTL Controller Errors Count" as both are described as "Cleanup Controller Errors Count". This change would reflect in the left menu what is specific to the TTL controller.
    
    Signed-off-by: François Duthilleul <francoisduthilleul@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit f7425b8bfd33a970225eb2c483cf4eefeeab23d3[m
Author: François Duthilleul <francoisduthilleul@gmail.com>
Date:   Fri Feb 7 07:51:34 2025 +0100

    Update tips.md (#1471)
    
    The command "kubectl get kyverno -A" is not working for me on the Killercoda playground whereas "kubectl get crd | grep kyverno" does work. I suggest to verify and change if required.
    
    controlplane $ kubectl -n kyverno get po
    NAME                                             READY   STATUS    RESTARTS   AGE
    kyverno-admission-controller-5db56b9fdc-czxb2    1/1     Running   0          12m
    kyverno-background-controller-76cd686bf7-rh785   1/1     Running   0          12m
    kyverno-cleanup-controller-6c99cd9d4-57999       1/1     Running   0          12m
    kyverno-reports-controller-76d69d697d-67bml      1/1     Running   0          12m
    controlplane $ kubectl get kyverno -A
    No resources found
    controlplane $ kubectl get crd | grep kyverno
    cleanuppolicies.kyverno.io                            2025-02-06T11:02:08Z
    clustercleanuppolicies.kyverno.io                     2025-02-06T11:02:08Z
    clusterephemeralreports.reports.kyverno.io            2025-02-06T11:02:08Z
    clusterpolicies.kyverno.io                            2025-02-06T11:02:09Z
    ephemeralreports.reports.kyverno.io                   2025-02-06T11:02:08Z
    globalcontextentries.kyverno.io                       2025-02-06T11:02:08Z
    policies.kyverno.io                                   2025-02-06T11:02:09Z
    policyexceptions.kyverno.io                           2025-02-06T11:02:08Z
    updaterequests.kyverno.io                             2025-02-06T11:02:08Z
    
    Signed-off-by: François Duthilleul <francoisduthilleul@gmail.com>

[33mcommit 7676005ef568905db77925ace9df6111fe4399a5[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Thu Feb 6 15:15:52 2025 +0800

    chore(deps): bump github.com/go-git/go-git/v5 from 5.11.0 to 5.13.0 in /render (#1466)
    
    chore(deps): bump github.com/go-git/go-git/v5 in /render
    
    Bumps [github.com/go-git/go-git/v5](https://github.com/go-git/go-git) from 5.11.0 to 5.13.0.
    - [Release notes](https://github.com/go-git/go-git/releases)
    - [Commits](https://github.com/go-git/go-git/compare/v5.11.0...v5.13.0)
    
    ---
    updated-dependencies:
    - dependency-name: github.com/go-git/go-git/v5
      dependency-type: direct:production
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 78dbd0a6afc5fdca3e913985da94ebab726e1fb8[m
Author: SONALI SRIVASTAVA <srivastava.sonali1@gmail.com>
Date:   Thu Feb 6 12:29:31 2025 +0530

    #1291 Updated sum function docs to mention array should not be empty (#1454)
    
    Updated sum function docs to mention array should not be empty
    
    Signed-off-by: Sonali Srivastava <srivastava.sonali1@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 16ead104e118a0ed3e03e648cc90696abfd008c7[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Thu Feb 6 14:55:43 2025 +0800

    chore(deps): bump golang.org/x/net from 0.25.0 to 0.33.0 in /render (#1467)
    
    Bumps [golang.org/x/net](https://github.com/golang/net) from 0.25.0 to 0.33.0.
    - [Commits](https://github.com/golang/net/compare/v0.25.0...v0.33.0)
    
    ---
    updated-dependencies:
    - dependency-name: golang.org/x/net
      dependency-type: indirect
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 67bbbc19fc4b5fe17bd76c02c38bbaa0264f6909[m
Author: François Duthilleul <francoisduthilleul@gmail.com>
Date:   Thu Feb 6 07:46:28 2025 +0100

    Update _index.md (#1468)
    
    Missing s
    
    Signed-off-by: François Duthilleul <francoisduthilleul@gmail.com>

[33mcommit 348a50ee90530e3f0408998a8b742a5cbef6b9f0[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Wed Feb 5 14:41:57 2025 +0800

    chore(deps): bump lycheeverse/lychee-action from 2.2.0 to 2.3.0 (#1464)
    
    Bumps [lycheeverse/lychee-action](https://github.com/lycheeverse/lychee-action) from 2.2.0 to 2.3.0.
    - [Release notes](https://github.com/lycheeverse/lychee-action/releases)
    - [Commits](https://github.com/lycheeverse/lychee-action/compare/f796c8b7d468feb9b8c0a46da3fac0af6874d374...f613c4a64e50d792e0b31ec34bbcbba12263c6a6)
    
    ---
    updated-dependencies:
    - dependency-name: lycheeverse/lychee-action
      dependency-type: direct:production
      update-type: version-update:semver-minor
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 29261f34756f65631b66901eb2e483c750a413a9[m
Author: Nish_ <120EE0980@nitrkl.ac.in>
Date:   Thu Jan 30 13:56:41 2025 +0530

    Removes schemaValidation field (#1463)
    
    Signed-off-by: Nish_ <120EE0980@nitrkl.ac.in>

[33mcommit 3e4876fb3aee98e87f2e983669725e1425edd618[m
Author: Rashi Chaubal <12rashic@gmail.com>
Date:   Mon Dec 30 14:34:02 2024 +0530

    Fix: Fixed the link for assertion tress in documentation (#1459)
    
    Signed-off-by: Rashi Chaubal <12rashic@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit b0d3d57fc3cf677ba5d30965a0180785c52efc48[m
Author: Rashi Chaubal <12rashic@gmail.com>
Date:   Mon Dec 30 12:24:56 2024 +0530

    Fixed link for kubernetes extension installation (#1457)
    
    Fixed link for kubernetes extention installation
    
    Signed-off-by: Rashi Chaubal <12rashic@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 5990d29976cff2cf525fb57ab9580195a9e9266a[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Dec 29 22:17:54 2024 -0800

    render policies (#1453)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 237ce15fcf616a719da7870c032648781dfea74d[m
Author: Lakshmanan Samynathan <lakshmanan.psgit@gmail.com>
Date:   Fri Dec 20 16:46:03 2024 +0530

    Fix broken links and update ArgoCD header (#1452)

[33mcommit 1080bf2b81d3653645b4a74f721405a5bc27bfec[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Fri Dec 20 16:18:33 2024 +0800

    chore(deps): bump lycheeverse/lychee-action from 2.1.0 to 2.2.0 (#1450)
    
    Bumps [lycheeverse/lychee-action](https://github.com/lycheeverse/lychee-action) from 2.1.0 to 2.2.0.
    - [Release notes](https://github.com/lycheeverse/lychee-action/releases)
    - [Commits](https://github.com/lycheeverse/lychee-action/compare/f81112d0d2814ded911bd23e3beaa9dda9093915...f796c8b7d468feb9b8c0a46da3fac0af6874d374)
    
    ---
    updated-dependencies:
    - dependency-name: lycheeverse/lychee-action
      dependency-type: direct:production
      update-type: version-update:semver-minor
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 2228051250f44cfb079262aa2498c16cbf4bd969[m
Author: Ammar Yasser <aerosound161@gmail.com>
Date:   Thu Dec 19 09:45:15 2024 +0200

    chore: Add docs for mutate existing with the CLI (#1439)
    
    * chore: Add docs for mutate existing with the CLI
    
    Signed-off-by: aerosouund <aerosound161@gmail.com>
    
    * Update content/en/docs/kyverno-cli/usage/test.md
    
    Co-authored-by: shuting <shuting@nirmata.com>
    Signed-off-by: Ammar Yasser <aerosound161@gmail.com>
    
    ---------
    
    Signed-off-by: aerosouund <aerosound161@gmail.com>
    Signed-off-by: Ammar Yasser <aerosound161@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit b1601ab11964db74d49d2eab56138d4addc7d7d9[m
Author: SONALI SRIVASTAVA <srivastava.sonali1@gmail.com>
Date:   Wed Dec 18 12:49:55 2024 +0530

    #1444 Removed spell check from Kyverno Architecture image (#1447)
    
    * Removed spell check from Kyverno Architecture image
    
    Signed-off-by: Sonali Srivastava <srivastava.sonali1@gmail.com>
    
    * chore(deps): bump golang.org/x/crypto from 0.17.0 to 0.31.0 in /render (#1445)
    
    Bumps [golang.org/x/crypto](https://github.com/golang/crypto) from 0.17.0 to 0.31.0.
    - [Commits](https://github.com/golang/crypto/compare/v0.17.0...v0.31.0)
    
    ---
    updated-dependencies:
    - dependency-name: golang.org/x/crypto
      dependency-type: indirect
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
    Signed-off-by: Sonali Srivastava <srivastava.sonali1@gmail.com>
    
    ---------
    
    Signed-off-by: Sonali Srivastava <srivastava.sonali1@gmail.com>
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 1bbefa6e9d573924fbe5d5f07800bdb1a4cff3e1[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Mon Dec 16 22:51:07 2024 -0800

    chore(deps): bump golang.org/x/crypto from 0.17.0 to 0.31.0 in /render (#1445)
    
    Bumps [golang.org/x/crypto](https://github.com/golang/crypto) from 0.17.0 to 0.31.0.
    - [Commits](https://github.com/golang/crypto/compare/v0.17.0...v0.31.0)
    
    ---
    updated-dependencies:
    - dependency-name: golang.org/x/crypto
      dependency-type: indirect
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit e9316784cb8e262ca63dc4b0f869ef798fae01a6[m
Author: Thomas P. <TPXP@users.noreply.github.com>
Date:   Fri Dec 6 09:42:13 2024 +0100

    fix(mutate): drop mention of the last-applied-patches annotation (#1442)
    
    The annotation has been dropped according to https://github.com/kyverno/kyverno/issues/5164
    
    Also, mention that by default Kyverno does not emit PolicyApplied events
    
    Signed-off-by: Thomas P. <TPXP@users.noreply.github.com>

[33mcommit be7519fda7d033625da157ba8d11cf741c153a89[m
Merge: cb0f2d5a 352a38f0
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Wed Dec 4 13:20:06 2024 +0530

    Added documentation for DeletionPropagationPolicy for cleanupPolicy a… (#1426)

[33mcommit 352a38f000a96e0459e89b028b16afa8629169a0[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 4 08:43:24 2024 +0100

    review comment
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 0199aec1eb34b5e54f6bb8f05243ce4afb00dc98[m
Merge: 9124ea0f cb0f2d5a
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 3 20:19:24 2024 +0100

    Merge branch 'main' into docs/add-deletion-propagation-policy

[33mcommit 9124ea0fc860f4272a43914e9a86fd651c771e50[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 3 20:18:25 2024 +0100

    finalise doc
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit cb0f2d5a457b8223c6758449d6c997574a94ebee[m
Author: Mohd Kamaal <102820439+Mohdcode@users.noreply.github.com>
Date:   Tue Dec 3 05:32:20 2024 +0530

    Update ArgoCD docs for Kyverno Helm chart with ServerSideApply and di… (#1440)
    
    * Update ArgoCD docs for Kyverno Helm chart with ServerSideApply and diff guidance
    
    Signed-off-by: Kamaal <kamaal@macs-MacBook-Air.local>
    
    * Update content/en/docs/installation/platform-notes.md
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Kamaal <kamaal@macs-MacBook-Air.local>
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: Kamaal <kamaal@macs-MacBook-Air.local>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit d7364e0beb883aecc144f6836c1d2b6b80b2a11e[m
Author: ShivamJha2436 <shivamkumar87148@gmail.com>
Date:   Tue Nov 26 16:06:51 2024 +0530

    made a small fix
    
    Signed-off-by: ShivamJha2436 <shivamkumar87148@gmail.com>

[33mcommit f5e587bd68135280f81399767ab90c4746a44e7a[m
Author: ShivamJha2436 <shivamkumar87148@gmail.com>
Date:   Tue Nov 26 14:01:15 2024 +0530

    fix/doc
    
    Signed-off-by: ShivamJha2436 <shivamkumar87148@gmail.com>

[33mcommit 4dbf0cc471a13fb5adde54223faf9a28c29cd65a[m
Author: ShivamJha2436 <shivamkumar87148@gmail.com>
Date:   Tue Nov 26 13:44:22 2024 +0530

    fix/doc
    
    Signed-off-by: ShivamJha2436 <shivamkumar87148@gmail.com>

[33mcommit 5fb8659b67a8fdd3f897bf24f49b9aaa3892f2ba[m
Author: ShivamJha2436 <shivamkumar87148@gmail.com>
Date:   Mon Nov 25 19:19:56 2024 +0530

    Minor changes in ttl
    
    Signed-off-by: ShivamJha2436 <shivamkumar87148@gmail.com>

[33mcommit 632b3d159c36cf7a6a3f9ded3770614dfb026ad4[m
Author: ShivamJha2436 <shivamkumar87148@gmail.com>
Date:   Mon Nov 25 18:49:08 2024 +0530

    Fix minor changes
    
    Signed-off-by: ShivamJha2436 <shivamkumar87148@gmail.com>

[33mcommit 49a21ee0faf59ffc42c2f756432e0c15611799cf[m
Author: ShivamJha2436 <shivamkumar87148@gmail.com>
Date:   Mon Nov 25 18:41:03 2024 +0530

    Updated the doc
    
    Signed-off-by: ShivamJha2436 <shivamkumar87148@gmail.com>

[33mcommit 930e5ad4316410caf6136de2effe9a2fd84ff505[m
Author: ShivamJha2436 <shivamkumar87148@gmail.com>
Date:   Mon Nov 25 16:16:40 2024 +0530

    Added link to the Customizing Permissions section
    
    Signed-off-by: ShivamJha2436 <shivamkumar87148@gmail.com>

[33mcommit 5247e12a735babf0011690a2e4dcd28bd3f71e44[m
Author: ShivamJha2436 <shivamkumar87148@gmail.com>
Date:   Mon Nov 25 15:50:44 2024 +0530

    Minor fixes
    
    Signed-off-by: ShivamJha2436 <shivamkumar87148@gmail.com>

[33mcommit 09acc64eac918f66864c666bd569810aebf78479[m
Merge: c0a774ef e75c8e44
Author: Shivam Kumar <122988410+ShivamJha2436@users.noreply.github.com>
Date:   Wed Nov 20 16:20:18 2024 +0530

    Merge branch 'main' into docs/add-deletion-propagation-policy

[33mcommit e75c8e44baa254fa9eb67f1b44da4b88bbca2d7c[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Nov 14 13:47:17 2024 +0530

    feat: Add imageIndex field to imageData (#1433)
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Co-authored-by: ShutingZhao <shuting@nirmata.com>

[33mcommit c0a774ef814b14a2508efaff56b68721a8fe9b92[m
Author: ShivamJha2436 <shivamkumar87148@gmail.com>
Date:   Wed Nov 13 12:28:14 2024 +0530

    Updated the doc
    
    Signed-off-by: ShivamJha2436 <shivamkumar87148@gmail.com>

[33mcommit cb0f70da9b542bf894f5610e4dabacd0975a0f10[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Fri Nov 8 15:15:45 2024 +0800

    chore(deps): bump lycheeverse/lychee-action from 2.0.2 to 2.1.0 (#1434)
    
    Bumps [lycheeverse/lychee-action](https://github.com/lycheeverse/lychee-action) from 2.0.2 to 2.1.0.
    - [Release notes](https://github.com/lycheeverse/lychee-action/releases)
    - [Commits](https://github.com/lycheeverse/lychee-action/compare/7cd0af4c74a61395d455af97419279d86aafaede...f81112d0d2814ded911bd23e3beaa9dda9093915)
    
    ---
    updated-dependencies:
    - dependency-name: lycheeverse/lychee-action
      dependency-type: direct:production
      update-type: version-update:semver-minor
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 6c074db9fe4f9848b3dfd7a7576feb5480fae8af[m
Author: shuting <shuting@nirmata.com>
Date:   Thu Nov 7 15:54:15 2024 +0800

    Revert "feat: Add imageIndex field to imageData" (#1431)
    
    Revert "feat: Add imageIndex field to imageData (#1362)"
    
    This reverts commit 66ed9c09367df0f570fc400f83c41ff70261acac.

[33mcommit 917c908a62f95ce7d95a5cf797ff200ac48be058[m
Author: shuting <shuting@nirmata.com>
Date:   Wed Nov 6 18:42:13 2024 +0800

    feat: add upgrade guidance for dropped api versions (#1429)
    
    feat: add upgrade guidance for dropped api verions
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit a6e32c84ee8366cfbf207ea0093bd0a26294327e[m
Author: shuting <shuting@nirmata.com>
Date:   Tue Nov 5 23:23:56 2024 +0800

    Reschedule community meeting (#1427)
    
    * reschedule community meeting
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * fix typo
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 6f68b1a95f4487883936709a77d9f633186b81a5[m
Author: Khaled Emara <khaled.emara@nirmata.com>
Date:   Tue Nov 5 10:13:45 2024 +0200

    doc(release): update release instructions (#1408)
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 56f784d6287bc9cf82a2c04f81065116686ed786[m
Author: ShivamJha2436 <shivamkumar87148@gmail.com>
Date:   Tue Nov 5 10:38:14 2024 +0530

    Added documentation for DeletionPropagationPolicy for cleanupPolicy and TTL-based cleanup resources
    
    Signed-off-by: ShivamJha2436 <shivamkumar87148@gmail.com>

[33mcommit c3186c893564a8ee5dd6beb1b3a9c32c545ca0e4[m
Merge: ee59252e 2d29a900
Author: Frank Jogeleit <frank.jogeleit@web.de>
Date:   Mon Nov 4 20:04:37 2024 +0100

    fix typo (#1424)

[33mcommit 2d29a90088b628bfe3d673c47b6a7101edb40cb3[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Nov 4 08:32:46 2024 -0800

    fix typo
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit ee59252edd939ed32a0356db272781b1c6c225d0[m
Author: shuting <shuting@nirmata.com>
Date:   Mon Nov 4 23:45:35 2024 +0800

    Add 1.13 release blog (#1422)
    
    * add version 1.13.0 to menu (cherry-pick #1404) (#1405)
    
    add version 1.13.0 to menu (#1404)
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    Co-authored-by: Khaled Emara <khaled.emara@nirmata.com>
    
    * change version to 1.13.0 (#1406)
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    
    * change menu version string (#1407)
    
    change version_menu to 1.13.0
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    
    * add 1.13 release blog
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Co-authored-by: gcp-cherry-pick-bot[bot] <98988430+gcp-cherry-pick-bot[bot]@users.noreply.github.com>
    Co-authored-by: Khaled Emara <khaled.emara@nirmata.com>

[33mcommit a727e3bec0c4c8a38f1c33f3bdffeee14700d65c[m
Author: Fernando Ripoll <fernando@giantswarm.io>
Date:   Mon Nov 4 10:58:29 2024 +0100

    Fix typos in the introduction page (#1420)
    
    Signed-off-by: Fernando Ripoll <fernando@giantswarm.io>

[33mcommit 453fcdc201ec0d3470141ba26fe61e67a6fdc250[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Nov 3 20:40:15 2024 -0800

    update quickstart generate sample (#1418)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 181181f7a5504aa4eaeea76135baae65f556c49c[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Nov 3 01:26:59 2024 -0700

    fix quickstart (#1416)

[33mcommit 9f4a0244870d1ae7f9f28e4b91457e15d686caf3[m
Author: Sebastian Gaiser <sebastiangaiser@users.noreply.github.com>
Date:   Thu Oct 31 11:30:32 2024 +0100

    fix(upgrading): v1.13 use correct Helm values (#1414)
    
    Signed-off-by: Sebastian Gaiser <sebastiangaiser@users.noreply.github.com>

[33mcommit 10412d71cefd3dd2b407a3e35b45a8fd2a16fbb5[m
Author: Khaled Emara <khaled.emara@nirmata.com>
Date:   Tue Oct 29 17:15:52 2024 +0300

    add version 1.13.0 to menu (#1404)
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>

[33mcommit 3a93f7082de07aae29e714e4a33b60c0333b43c5[m
Author: Khaled Emara <khaled.emara@nirmata.com>
Date:   Tue Oct 29 16:58:16 2024 +0300

    doc(scale): update scale numbers for 1.13 (#1374)
    
    * doc(scale): update scale numbers for 1.13
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    
    * feat: update scaling numbers for 1.13.0-rc.2
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * chore: point to latest test script
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Co-authored-by: ShutingZhao <shuting@nirmata.com>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit f59a17283cdae50e21f0261fd76be5ce79078ae1[m
Author: Marc Brugger <github@bakito.ch>
Date:   Tue Oct 29 14:57:49 2024 +0100

    [1.13] support inline exceptions in cli apply (#1234)
    
    support inline exceptions in cli apply
    
    Signed-off-by: bakito <github@bakito.ch>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit aa06dd77b46af3b7c4bd41c79209956a676c16f6[m
Author: Khaled Emara <khaled.emara@nirmata.com>
Date:   Tue Oct 29 16:57:28 2024 +0300

    doc(gctx): cli variable injection (#1323)
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 125df1793f698a3f2db4f6a2796f0764a6e62a6d[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Tue Oct 29 16:35:24 2024 +0530

    fix: add warning to set permission in reports controller (#1403)
    
    * fix: add warning to set permission in reports controller
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * feat: update note
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * fix: case in kyverno
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 42569c0fcd2c5fa6fb4ad7b1cbfe65766c3b3cbd[m
Author: shuting <shuting@nirmata.com>
Date:   Tue Oct 29 18:41:39 2024 +0800

    chore: link to CVE (#1402)
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 01e599a7a60ba440fc548487ae2166ecda99c7a9[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 28 15:33:56 2024 -0700

    fix links (#1399)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 7451b092ab3257e23591e2288e6d2f8ed725fb39[m
Author: Frank Jogeleit <frank.jogeleit@web.de>
Date:   Mon Oct 28 23:16:05 2024 +0100

    [Enhancement] assert subrule documentation (#1329)
    
    add assert subrule documentation
    
    Signed-off-by: Frank Jogeleit <frank.jogeleit@web.de>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 051ad9813a7c4f1fde000e5a0dd9c7e312297ca3[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Mon Oct 28 21:40:27 2024 +0530

    feat: add documentation for auto webhook deletion feature (#1398)
    
    * feat: add documentation for auto webhook deletion feature
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * fix: clarifications
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 904d8fa9ea12e5fcba18a2712cde28d459967e06[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Mon Oct 28 21:16:00 2024 +0530

    feat: add documentation for emit warning in mutate and validate (#1397)
    
    * feat: add documentation for emit warning in mutate and validate
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update validate.md
    
    Co-authored-by: shuting <shutting06@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.chdhry.work@gmail.com>
    
    * Update mutate.md
    
    Co-authored-by: shuting <shutting06@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.chdhry.work@gmail.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Signed-off-by: Vishal Choudhary <vishal.chdhry.work@gmail.com>
    Co-authored-by: shuting <shutting06@gmail.com>

[33mcommit 85408591ff34a24a5c7ceec5b768edc64e7485f1[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Mon Oct 28 21:13:17 2024 +0530

    feat: Documentation for TSA cert chain support for cosign in verify images rules (#1396)
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 66ad8540d0509662ddd12d23735c9ccd103347a3[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Mon Oct 28 14:21:17 2024 +0300

    chore: add docs for disabling exceptions by default (#1395)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>

[33mcommit 16d64e44b8baf473fcac4082e86858d6d6398abb[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Oct 27 23:02:46 2024 -0700

    Docs for 1.13 upgrade (#1394)
    
    * document breaking changes
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * document breaking changes
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 9d433cea6924ab36de11d8489a2186fee5ab2701[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Oct 27 23:01:52 2024 -0700

    update products (#1393)
    
    * update products
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * fix link
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 647765ba0381a4f8f08b511b9684d03826a1f520[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Mon Oct 28 02:23:04 2024 +0300

    docs: use v2 for cleanup policies and exceptions (#1372)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>

[33mcommit e2f15333b1b99f8ae5a46f1f4979bd38964e84f1[m
Author: Arturo Borrero Gonzalez <arturo.bg@arturo.bg>
Date:   Mon Oct 28 00:22:14 2024 +0100

    docs: installation: scaling: mention kubernetes core components resou… (#1295)
    
    docs: installation: scaling: mention kubernetes core components resources footprint
    
    Introduce a mention to how many kyverno resources may impact the
    kubernetes core components regarding their resources footprint.
    
    See also: https://github.com/kyverno/kyverno/issues/10458
    
    Signed-off-by: Arturo Borrero Gonzalez <aborrero@wikimedia.org>
    Co-authored-by: Arturo Borrero Gonzalez <aborrero@wikimedia.org>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 86cd83f0f88d2198d283f9363d9cd07a49424b16[m
Author: Ammar Yasser <aerosound161@gmail.com>
Date:   Mon Oct 28 02:21:32 2024 +0300

    docs: Show an example for selecting targets with labels (#1373)
    
    Signed-off-by: aerosouund <aerosound161@gmail.com>

[33mcommit 6f1653f7c919c88fc94839b36b3201023f126d8c[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Mon Oct 28 02:19:42 2024 +0300

    docs: add warning for the validationFailureAction deprecated field (#1345)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>

[33mcommit 1ba849a81fdbabffc2f561bbdd5ebcf29e5dc512[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Mon Oct 28 04:48:36 2024 +0530

    feat(docs): regexp support in cosign keyless verification (#1327)
    
    * feat(docs): regexp support in cosign keyless verification
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * fix: grammatical errors
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit b692d4ef29c5d901c182cef47f0926c7ca8853f0[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Mon Oct 28 02:16:55 2024 +0300

    docs: add --dumpPatches flag (#1386)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>

[33mcommit 0b6e2cac63af2ff5b9457f2818ef2b63b993b7b7[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Fri Oct 25 13:50:20 2024 +0530

    feat: add documentation for new reporting configuration changes (#1389)
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit daab8d1c75354883d2ad6cb1e2c416e01037324f[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Thu Oct 24 13:48:18 2024 +0800

    chore(deps): bump actions/checkout from 4.2.1 to 4.2.2 (#1390)
    
    Bumps [actions/checkout](https://github.com/actions/checkout) from 4.2.1 to 4.2.2.
    - [Release notes](https://github.com/actions/checkout/releases)
    - [Changelog](https://github.com/actions/checkout/blob/main/CHANGELOG.md)
    - [Commits](https://github.com/actions/checkout/compare/eef61447b9ff4aafe5dcd4e0bbf5d482be7e7871...11bd71901bbe5b1630ceea73d27597364c9af683)
    
    ---
    updated-dependencies:
    - dependency-name: actions/checkout
      dependency-type: direct:production
      update-type: version-update:semver-patch
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 444baa756ed3eda23c3ea029ac3b2400d37e2765[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Tue Oct 15 12:51:08 2024 +0800

    chore(deps): bump lycheeverse/lychee-action from 2.0.1 to 2.0.2 (#1387)
    
    Bumps [lycheeverse/lychee-action](https://github.com/lycheeverse/lychee-action) from 2.0.1 to 2.0.2.
    - [Release notes](https://github.com/lycheeverse/lychee-action/releases)
    - [Commits](https://github.com/lycheeverse/lychee-action/compare/2bb232618be239862e31382c5c0eaeba12e5e966...7cd0af4c74a61395d455af97419279d86aafaede)
    
    ---
    updated-dependencies:
    - dependency-name: lycheeverse/lychee-action
      dependency-type: direct:production
      update-type: version-update:semver-patch
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 9108a409243c1092094147db3b86a6623b9d478d[m
Merge: 8ce82a79 b7072adc
Author: Vishal Choudhary <vishal.chdhry.work@gmail.com>
Date:   Mon Oct 14 19:30:55 2024 +0530

    docs: add warning for the generateExisting deprecated field (#1385)

[33mcommit 8ce82a7970f9ef1bee43daf1f75720c1df4143d4[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Mon Oct 14 16:50:52 2024 +0300

    docs: add warning for the mutateExistingOnPolicyUpdate deprecated field (#1384)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit a29e175a8b50008e671cc6e120a90a66f36ca7bf[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 14 06:49:52 2024 -0700

    Simplify instllation (#1382)
    
    * add shallow substitution docs
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * update installation instructions
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * fix link
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 69c4d1bc5ad6298b8a7a0a3b3f30ac36e42db939[m
Author: Ammar Yasser <aerosound161@gmail.com>
Date:   Mon Oct 14 16:38:00 2024 +0300

    docs: Add maxBackgroundReports flag documentation (#1381)
    
    * docs: Add maxBackgroundReports flag documentation
    
    Signed-off-by: aerosouund <aerosound161@gmail.com>
    
    * chore: Update flag docs to use ephemeralreports instead of background reports as changed in the container flag itself
    
    Signed-off-by: aerosouund <aerosound161@gmail.com>
    
    ---------
    
    Signed-off-by: aerosouund <aerosound161@gmail.com>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit b7072adc0f2ba7679db4fe32ebb3b8bbea79960f[m
Author: Mariam Fahmy <mariam.fahmy@nirmata.com>
Date:   Mon Oct 14 14:55:18 2024 +0300

    docs: add warning for the generateExisting deprecated field
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>

[33mcommit b7a815c77453c93e76092410ab07a718bef8d953[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Mon Oct 14 15:30:28 2024 +0800

    chore(deps): bump lycheeverse/lychee-action from 2.0.0 to 2.0.1 (#1383)
    
    Bumps [lycheeverse/lychee-action](https://github.com/lycheeverse/lychee-action) from 2.0.0 to 2.0.1.
    - [Release notes](https://github.com/lycheeverse/lychee-action/releases)
    - [Commits](https://github.com/lycheeverse/lychee-action/compare/7da8ec1fc4e01b5a12062ac6c589c10a4ce70d67...2bb232618be239862e31382c5c0eaeba12e5e966)
    
    ---
    updated-dependencies:
    - dependency-name: lycheeverse/lychee-action
      dependency-type: direct:production
      update-type: version-update:semver-patch
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 78347b337a5551434dd04f0b782d27a7f2a7c445[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Oct 13 20:59:03 2024 -0700

    add shallow substitution docs (#1377)

[33mcommit 9ed98d6b73e193ab3f3ff6b80f3938b37e63c4b7[m
Author: abirsigron <abirsigron@gmail.com>
Date:   Sun Oct 13 22:07:05 2024 +0300

    Credit for the idea of Assigning Node Metadata to Pods (#1344)
    
    * Credit to Abir Sigron
    
    Signed-off-by: abirsigron <abirsigron@gmail.com>
    
    * Fix credit phrasing
    
    Signed-off-by: abirsigron <abirsigron@gmail.com>
    
    ---------
    
    Signed-off-by: abirsigron <abirsigron@gmail.com>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 088f7bbdc411d4f285eb4cb80ececaed3ac5f651[m
Author: Ammar Yasser <aerosound161@gmail.com>
Date:   Wed Oct 9 17:53:56 2024 +0300

    docs: Modify patchedResource key in variables to be patchedResources (#1380)
    
    Signed-off-by: aerosouund <aerosound161@gmail.com>

[33mcommit 846d8236f5e6748c23af8a7207089352d2aa49c8[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Oct 8 20:14:10 2024 -0700

    fix footer; update banner (#1376)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 7e798764f81d3db3bf94ee1263209269299d6216[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Wed Oct 9 11:13:22 2024 +0800

    chore(deps): bump lycheeverse/lychee-action from 1.10.0 to 2.0.0 (#1378)
    
    Bumps [lycheeverse/lychee-action](https://github.com/lycheeverse/lychee-action) from 1.10.0 to 2.0.0.
    - [Release notes](https://github.com/lycheeverse/lychee-action/releases)
    - [Commits](https://github.com/lycheeverse/lychee-action/compare/2b973e86fc7b1f6b36a93795fe2c9c6ae1118621...7da8ec1fc4e01b5a12062ac6c589c10a4ce70d67)
    
    ---
    updated-dependencies:
    - dependency-name: lycheeverse/lychee-action
      dependency-type: direct:production
      update-type: version-update:semver-major
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 95b13ce1da86a0ee9aea3f33a35da2ac27cdf6e2[m
Author: Norbert Szulc <norbert@not7cd.net>
Date:   Tue Oct 8 22:46:18 2024 +0200

    Enable CORS for RSS feed (#1369)
    
    This will allow using the feed in a Grafana dashboard news panel.
    
    Signed-off-by: Norbert Szulc <norbert@not7cd.net>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 03c1967d402a48cb8c5c95fb20309e48f7e44faa[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Tue Oct 8 18:21:16 2024 +0800

    chore(deps): bump actions/checkout from 4.2.0 to 4.2.1 (#1375)
    
    Bumps [actions/checkout](https://github.com/actions/checkout) from 4.2.0 to 4.2.1.
    - [Release notes](https://github.com/actions/checkout/releases)
    - [Changelog](https://github.com/actions/checkout/blob/main/CHANGELOG.md)
    - [Commits](https://github.com/actions/checkout/compare/d632683dd7b4114ad314bca15554477dd762a938...eef61447b9ff4aafe5dcd4e0bbf5d482be7e7871)
    
    ---
    updated-dependencies:
    - dependency-name: actions/checkout
      dependency-type: direct:production
      update-type: version-update:semver-patch
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit ca700e95cc6f879f7ce5cbfdf8f43aaee14cecf5[m
Author: A. Singh <32884734+A-5ingh@users.noreply.github.com>
Date:   Mon Sep 30 03:07:08 2024 -0400

    chore: updated JMESPath function (#1371)
    
    Signed-off-by: GitHub <noreply@github.com>

[33mcommit a78e00342bf923515be522065bd73669867c862e[m
Author: A. Singh <32884734+A-5ingh@users.noreply.github.com>
Date:   Mon Sep 30 01:09:39 2024 -0400

    doc: update hugo installation for github codespaces users (#1370)
    
    * doc: update hugo installation for github codespaces users
    
    Signed-off-by: A. Singh <32884734+A-5ingh@users.noreply.github.com>
    
    * Update README.md
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: A. Singh <32884734+A-5ingh@users.noreply.github.com>
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 88196ca2c6fa519f429d0fb6ace8aafe85dc636f[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Fri Sep 27 08:54:30 2024 +0530

    feat: remove beta warning from image verify, exceptions and cleanup policy docs (#1366)
    
    feat: remove beta warning from image verify, exceptions and cleanup policy doc
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 3331b544027c286471685a3fe7f19f812b7cfcdd[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Thu Sep 26 23:24:35 2024 +0300

    add docs for VAPs (#1358)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>

[33mcommit d5c01d91df68bc670bd9e929867d6dcff37bbb2c[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 26 20:14:04 2024 +0530

    feat (docs): add support for signature algorithm in cosign cert and kms verification (#1337)
    
    * feat (docs): add support for signature algorithm in cosign cert and kms verification
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * fix: case
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * fix: add signature algorithms
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit e48845e9ee7924924042761f7df11d62a596f512[m
Merge: 36fd0c6d 40ece26e
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 26 20:04:13 2024 +0530

    [1.13] add documentation for for condition validation across multiple image verification attestations or context entry (#1300)

[33mcommit 40ece26e532b6674df1714e13787a57e7e3c1039[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 26 20:02:54 2024 +0530

    fix: refactor
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 58c4ef907f759fe56f1ef08dbee8527406dec498[m
Merge: 6f4982fa 36fd0c6d
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 26 19:47:20 2024 +0530

    Merge branch 'main' into feat-#9456

[33mcommit 6f4982fa933ab2dd8e7273fffe0c2e89e007351f[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 26 19:40:49 2024 +0530

    fix: refactor
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 36fd0c6da034a917dafa9003a5439f2384f0f812[m
Merge: 1bb401a9 051966a4
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 26 19:28:57 2024 +0530

    [1.13] default field in apiCall (#1301)

[33mcommit 051966a49dc6405d037cd45b8e79e093390baf7f[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 26 19:27:57 2024 +0530

    fix: cleanup
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 08d2ef51912ab0cf803249a3d003b2c163fc4eb3[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 26 19:25:31 2024 +0530

    fix: docs
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit e7fa7742839e467886b0b5cd6e85d90b48ac4845[m
Merge: 421f979f 1bb401a9
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 26 19:21:09 2024 +0530

    Merge branch 'main' into default-for-apiCall

[33mcommit 1bb401a9a3106eeee214569a2eb7de9e73e46461[m
Author: shuting <shuting@nirmata.com>
Date:   Thu Sep 26 21:49:29 2024 +0800

    feat: add generate foreach (#1357)
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 25dbcd78f6ce2f51d841f9e34226be70d91b8a26[m
Author: shuting <shuting@nirmata.com>
Date:   Thu Sep 26 19:14:34 2024 +0800

    feat: update on metrics exposure config (#1363)
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 66ed9c09367df0f570fc400f83c41ff70261acac[m
Author: shuting <shuting@nirmata.com>
Date:   Thu Sep 26 19:12:43 2024 +0800

    feat: Add imageIndex field to imageData (#1362)
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 56e82c66c2f0b3d42580ad23a7f8bcd775a2bd47[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 26 16:26:42 2024 +0530

    feat(docs): add docs for sigstore bundle verification (#1328)
    
    feat(docs): sigstore bundle verification
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 9e4003560d245b8476e2468197ffb0da66ddd397[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Thu Sep 26 18:45:37 2024 +0800

    chore(deps): bump actions/checkout from 4.1.7 to 4.2.0 (#1361)
    
    Bumps [actions/checkout](https://github.com/actions/checkout) from 4.1.7 to 4.2.0.
    - [Release notes](https://github.com/actions/checkout/releases)
    - [Changelog](https://github.com/actions/checkout/blob/main/CHANGELOG.md)
    - [Commits](https://github.com/actions/checkout/compare/692973e3d937129bcbf40652eb9f2f61becf3332...d632683dd7b4114ad314bca15554477dd762a938)
    
    ---
    updated-dependencies:
    - dependency-name: actions/checkout
      dependency-type: direct:production
      update-type: version-update:semver-minor
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 50717d223146711bc8429f5b1f9d920c21ad3e87[m
Merge: ad2a8335 4e8d1d02
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 19 15:03:48 2024 +0530

    fix: add documentation for validate.allowExistingViolations (#1354)

[33mcommit 4e8d1d02ccec6d86366412fc988d8ae60877af41[m
Merge: 680f6569 ad2a8335
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 19 15:02:45 2024 +0530

    Merge branch 'main' into allowExistingViolations-doc

[33mcommit ad2a8335df08e0cf6fbb565065bc688b2fc11414[m
Author: shuting <shuting@nirmata.com>
Date:   Thu Sep 19 16:36:02 2024 +0800

    feat: add 1.13 to compatibility matrix (#1356)
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 680f6569c402595e9aac4f67e1e2c62fb9d6666f[m
Merge: 4cfd0ce3 c992d80c
Author: shuting <shuting@nirmata.com>
Date:   Thu Sep 19 16:09:54 2024 +0800

    Merge branch 'main' into allowExistingViolations-doc

[33mcommit c992d80c9d49bf88b5d740595a103dfc74809d5e[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 19 13:39:32 2024 +0530

    fix: update broken links (#1355)
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 4cfd0ce3f62b79a6f36c3ff3b5584dc64287d0e0[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 19 12:56:05 2024 +0530

    fix: use rule not policy
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 6b5cbaf3a46019ba3df48491670f0e57562e4f0b[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Thu Sep 19 12:54:52 2024 +0530

    feat: add docs for allowExistingviolations
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 874e6e6d5b55ee7c5acf41666887882a41628683[m
Author: Di Xu <stephenhsu90@gmail.com>
Date:   Wed Sep 18 18:48:25 2024 +0800

    update certificates renewal time before expiration (#1350)
    
    Signed-off-by: Di Xu <stephenhsu90@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit f454dd954fdfffc198684e32b3c0d13d9cd991b5[m
Author: Marcus Vaal <mjvaal@gmail.com>
Date:   Wed Sep 18 02:29:51 2024 -0500

    fix(docs): Updated mutateExistingOnPolicyUpdate documentation to include validation info (#1346)
    
    * fix: Updated mutateExistingOnPolicyUpdate documentation to include validation info
    
    Signed-off-by: mvaal <mvaal@expediagroup.com>
    
    * Formatting and wording update
    
    Signed-off-by: mvaal <mvaal@expediagroup.com>
    
    * Corrected consistency issue and fixed documentation language.
    
    Signed-off-by: mvaal <mvaal@expediagroup.com>
    
    ---------
    
    Signed-off-by: mvaal <mvaal@expediagroup.com>
    Co-authored-by: mvaal <mvaal@expediagroup.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 864da56e4df1150b3e9794221b9c6425f2365d32[m
Author: Ammar Yasser <aerosound161@gmail.com>
Date:   Mon Sep 16 11:03:00 2024 +0300

    docs: Mention that DELETE should be specified if mutation on deletion is required (#1348)
    
    Signed-off-by: aerosouund <aerosound161@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit a4fe3663e904a1eb99df1924f852f03de22fc54b[m
Author: Sanskar Gurdasani <92817635+Sanskarzz@users.noreply.github.com>
Date:   Mon Sep 16 12:33:00 2024 +0530

    chore: add kyverno-envoy-plugin blog post (#1270)
    
    * chore: add kyverno-envoy-plugin blog post
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * fix ci error...
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * added architecture diagrams
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * Update content/en/blog/general/introducing-kyverno-envoy-plugin/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Sanskar Gurdasani <92817635+Sanskarzz@users.noreply.github.com>
    
    * Update content/en/blog/general/introducing-kyverno-envoy-plugin/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Sanskar Gurdasani <92817635+Sanskarzz@users.noreply.github.com>
    
    * removed punctuation in heading for markdown
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * add empty line around code fences
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * removed excessive new lines
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * fixed indentation in the policy samples
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * proper nouns are now titled cased
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * added suggested changes
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * some minor changes
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * Update content/en/blog/general/introducing-kyverno-envoy-plugin/index.md
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    Signed-off-by: Sanskar Gurdasani <92817635+Sanskarzz@users.noreply.github.com>
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 66cd1a0f52e0ed08abf8677f2d4161ae96552f4e[m
Author: Pradeep Lakshmi Narasimha <pradeep.vaishnav4@gmail.com>
Date:   Thu Sep 12 11:50:47 2024 +0530

    Replaced deprecated generateExistingOnPolicyUpdate with generateExisting (#1343)

[33mcommit daeb2992c21f17592ea0ff0139347bb62362da53[m
Author: A. Singh <32884734+A-5ingh@users.noreply.github.com>
Date:   Thu Sep 12 00:49:53 2024 -0400

    bugfix: webhooks in configmap keys (#1342)
    
    chore: update kube-system in config maps webhook
    
    Signed-off-by: GitHub <noreply@github.com>

[33mcommit 6cffc8aa35d3ce88ecdf343dc5992e78b00161c1[m
Author: A. Singh <32884734+A-5ingh@users.noreply.github.com>
Date:   Wed Sep 11 13:53:26 2024 -0400

    fix: update log4j security link (#1341)
    
    update log4j security link
    
    Signed-off-by: A. Singh <32884734+A-5ingh@users.noreply.github.com>

[33mcommit 6117e89eef6ddb0885c1f48eede8184f4401d74a[m
Author: Di Xu <stephenhsu90@gmail.com>
Date:   Tue Sep 10 00:06:10 2024 +0800

    minor update installation methods (#1339)
    
    Signed-off-by: Di Xu <stephenhsu90@gmail.com>

[33mcommit 2ee7df0cac813a70986fe4aecce1d11ebe080baa[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Aug 26 04:02:02 2024 -0700

    update RBAC customizations and sub-project info (#1320)
    
    * update RBAC customizations and sub-project info
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * fix links
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * fix links
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * update title
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * update quick start for generating secrets
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * reduce generate perms
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit cff961a3ee63915a835845aa4bd6d9bf91babd8c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Aug 20 19:38:14 2024 -0400

    update owners (#1331)
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit b87ed05214db4c60f0855c30a23cd89e3a756f19[m
Author: A. Singh <32884734+A-5ingh@users.noreply.github.com>
Date:   Thu Aug 15 14:08:15 2024 -0400

    bugfix: `Render` to cleanup all the directories (#1324)
    
    * fix: walk through all directories and subdirectories
    
    Signed-off-by: GitHub <noreply@github.com>
    
    * chore: added remove emptry directories functionality
    
    Signed-off-by: GitHub <noreply@github.com>
    
    ---------
    
    Signed-off-by: GitHub <noreply@github.com>

[33mcommit 301a004d83cc5fe424b9b1f52b543e9f38d140e8[m
Author: Pradeep Lakshmi Narasimha <pradeep.vaishnav4@gmail.com>
Date:   Tue Aug 13 16:25:00 2024 +0530

    fix: Updated doc for metric kyverno_policy_results_total to kyverno_policy_results #1325 (#1326)
    
    Signed-off-by: Pradeep Lakshmi Narasimha <pradeep.vaishnav4@gmail.com>

[33mcommit f82fc7b4199349bef3dd633be264ea0c947b208a[m
Author: Arjun Devarajan <arjund98@gmail.com>
Date:   Mon Aug 5 16:48:54 2024 -0400

    Add Scarf documentation pixel to site footer (#1321)
    
    Add Scarf documentation pixel to footer
    
    This PR updates the Kyverno documentation website by adding a pixel to the footer of the website. The pixel does not impact site speed times, does not contain cookies or JavaScript, and is purely an HTML image that collects basic de-identified download and adoption metrics.
    
    Signed-off-by: Arjun Devarajan <arjun@scarf.sh>

[33mcommit 17719abdd4c0defe0a47299912f94d6b9682df38[m
Author: kapistka <kapistka@gmail.com>
Date:   Sat Aug 3 22:24:05 2024 +0300

    Fix rekor.pubkey & ctlog.pubkey (#1319)
    
    Signed-off-by: kapistka <kapistka@gmail.com>

[33mcommit 0ba7b97fa4f989142091647fcaf603038945d84d[m
Author: shuting <shuting@nirmata.com>
Date:   Fri Aug 2 23:35:37 2024 +0800

    add cleanup controller (#1317)
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 3291f940dd3d48f2a5219dd7c9b26faf7612b691[m
Author: shuting <shuting@nirmata.com>
Date:   Fri Aug 2 12:56:17 2024 +0800

    feat: add cleanup controller to graphics (#1297)
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit f2f2b244aa62ff141fa2aee122068d17f063720d[m
Author: Nikhil Maheshwari <36232275+nikhilmaheshwari24@users.noreply.github.com>
Date:   Tue Jul 30 15:08:04 2024 +0530

    Enhance Resource Constraints Validation Policy to Include InitContainers (#1314)
    
    * Update require-pod-requests-limits.md
    
    Signed-off-by: Nikhil Maheshwari <36232275+nikhilmaheshwari24@users.noreply.github.com>
    
    * Update require-pod-requests-limits.md
    
    Signed-off-by: Nikhil Maheshwari <36232275+nikhilmaheshwari24@users.noreply.github.com>
    
    ---------
    
    Signed-off-by: Nikhil Maheshwari <36232275+nikhilmaheshwari24@users.noreply.github.com>

[33mcommit 8e96d73f265af6aafa2b80f370823187fac00a56[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 18 09:56:22 2024 -0700

    fix typo on the home page (#1310)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit bbdb8dc000c5f0cd27f853784a17f06166024f45[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Jul 17 09:43:44 2024 -0700

    Update governance (#1307)
    
    * Update governance
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * fix links
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * update main page and add sub-projects
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * Update content/en/_index.md
    
    Signed-off-by: shuting <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 6bf93001f9ee3f05ca879dd6014afff3ea45df7a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jul 15 03:38:57 2024 -0400

    Render policies (#1304)
    
    render
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 894c94429c695f44e8b6c4290b7d5a7b5519a280[m
Author: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
Date:   Mon Jul 15 01:29:28 2024 +0530

    add example for setting up grafana dashboard (#1243)
    
    * add example for setting up grafana dashboard
    
    Signed-off-by: Anushka Mittal <anushka@nirmata.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Update content/en/docs/monitoring/bonus-grafana-dashboard/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    ---------
    
    Signed-off-by: Anushka Mittal <anushka@nirmata.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 260357f34464080b1dae925a8d4b08f0f5703c99[m
Author: shuting <shuting@nirmata.com>
Date:   Mon Jul 15 03:57:03 2024 +0800

    feat: add configmap key `updateRequestThreshold` (#1282)
    
    feat: add configmap key updateRequestThreshold
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 0545de2cfa15e1144dfb66c37d76382f9e893eee[m
Author: Weru <fromweru@gmail.com>
Date:   Sun Jul 14 22:52:20 2024 +0300

    fix styling regressions (snippets, alerts, anchor links) (#1290)
    
    * fix styling regressions (snippets, alerts, anchor links)
    
    Signed-off-by: Weru <fromweru@gmail.com>
    
    * include anchor links while rendering headings
    
    Signed-off-by: Weru <fromweru@gmail.com>
    
    ---------
    
    Signed-off-by: Weru <fromweru@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit dde1014a9cdb06776c8d22f821d2b78640b07955[m
Author: shuting <shuting@nirmata.com>
Date:   Mon Jul 15 03:48:09 2024 +0800

    Add default for `--aggregationWorkers` (#1292)
    
    Signed-off-by: shuting <shuting@nirmata.com>

[33mcommit 421f979f13a01ee34a2173bfbfd9bc6c2ac054db[m
Author: sivasathyaseeelan <dnsiva.sathyaseelan.chy21@iitbhu.ac.in>
Date:   Wed Jul 3 16:05:46 2024 +0530

    docs for issue 9723
    
    Signed-off-by: sivasathyaseeelan <dnsiva.sathyaseelan.chy21@iitbhu.ac.in>

[33mcommit 5d7b6d1a74ee143cf1b62f0e9d8cf9b4584b2d0c[m
Author: sivasathyaseeelan <dnsiva.sathyaseelan.chy21@iitbhu.ac.in>
Date:   Tue Jul 2 12:33:47 2024 +0530

    added documentation for PR #9960
    
    Signed-off-by: sivasathyaseeelan <dnsiva.sathyaseelan.chy21@iitbhu.ac.in>

[33mcommit f2c13d85a1435c123fecf1a44d940df6dd9f3601[m
Author: Steven Sklar <sklarsa@gmail.com>
Date:   Mon Jul 1 16:41:44 2024 +0200

    Helm values.yaml file example doesn't work for high availability (#1299)
    
    Update methods.md
    
    Signed-off-by: Steven Sklar <sklarsa@gmail.com>

[33mcommit b337024139f9c361e4e90b94fec88c813014ad8c[m
Author: shuting <shuting@nirmata.com>
Date:   Fri Jun 28 23:43:26 2024 +0800

    chore: clarify mutate exisitng vs standard mutate policy (#1293)
    
    * chore: clarify mutate exisitng vs standard mutate policy
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * chore: update mutate existing
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * chore: formatting
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 8f532086d8f93349bdf1240795181af60befda4e[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Wed Jun 12 20:37:56 2024 -0400

    chore(deps): bump actions/checkout from 4.1.6 to 4.1.7 (#1287)
    
    Bumps [actions/checkout](https://github.com/actions/checkout) from 4.1.6 to 4.1.7.
    - [Release notes](https://github.com/actions/checkout/releases)
    - [Changelog](https://github.com/actions/checkout/blob/main/CHANGELOG.md)
    - [Commits](https://github.com/actions/checkout/compare/a5ac7e51b41094c92402da3b24376905380afc29...692973e3d937129bcbf40652eb9f2f61becf3332)
    
    ---
    updated-dependencies:
    - dependency-name: actions/checkout
      dependency-type: direct:production
      update-type: version-update:semver-patch
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit f8399d987f51be56867401c60fb977d3c3851a2f[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jun 12 06:37:26 2024 -0400

    add OWNERS.md (#1283)
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 2044aaae7662dd964ee675fa128c21d679e9244b[m
Author: Khaled Emara <khaled.emara@nirmata.com>
Date:   Tue Jun 11 16:25:55 2024 +0300

    doc(validate): add a section about conditional anchor with another pass/fail (#1248)
    
    * doc(validate): add a section about conditional anchor with another pass/fail
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    
    * doc(anchor): correct skipping section
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    
    * fix(reports): refer to the right anchor documentation
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    
    * Update content/en/docs/policy-reports/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 92a92a4112dd8c1c838ae0502b1108fe958d8615[m
Author: shuting <shuting@nirmata.com>
Date:   Tue Jun 11 21:21:37 2024 +0800

    Clarify project governance principle for subprojects (#1281)
    
    * chore: update pr management guidelines
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * chore: update slack channels
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * chore: update release planning
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * chore: clarify project roles for subprojects
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * chore: rephrase - clarify project roles for subprojects
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit b7e850373891260d02afca18b81ae5e059dd6866[m
Author: shuting <shuting@nirmata.com>
Date:   Mon Jun 10 19:02:48 2024 +0800

    Update Slack channels (#1277)
    
    * chore: update pr management guidelines
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * chore: update slack channels
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 250cf1a039206182c9227b97275f467adaa6c518[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jun 9 23:09:43 2024 -0700

    Improvements: remove Resources, edit Community & Policiies (#1276)
    
    remove Resources, edit Community & Polciies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit a5bb54af5a17b0561b8cb261128413ac466269f3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jun 10 02:08:19 2024 -0400

    add GKE docs link (#1275)
    
    * add GKE docs link
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * update AKS note
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit ed2056be920437155c13d60b003630289be1f84b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jun 8 18:16:42 2024 -0400

    Docsy bump to 0.10.0 and docs fixes/enhancements (#1274)
    
    * dump docsy theme to 0.10.0
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * Remove references to spec.schemaValidation
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add generate note for trigger sync re. preconditions
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * rewrite trust section
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix code fence
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix omitEvents
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add Combining Mutate and Generate
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add aggregationWorkers flag and fix others
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * linting
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * relax cleanup beta warning note
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * clarify note
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add mutate existing tips
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix and update CLI test examples
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add namespaceSelector to match
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 19c152f6b4925e3f6c7d39fb07fd82d9d097a63e[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Wed Jun 5 18:51:24 2024 +0530

    feat: add reports server performance benchmarks with kyverno v1.12.3 (#1267)
    
    * feat: add reports server performance benchmarks with kyverno v1.12.3
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * fix: add requested changes
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit de3d3ca04233f6efe477e7c77cce6229bdaf12e1[m
Author: shuting <shuting@nirmata.com>
Date:   Wed Jun 5 03:39:45 2024 +0800

    chore: update pr management guidelines (#1261)
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit f157be4bbacdb3fcd2611a4c960ddd5defefc27f[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jun 3 09:55:55 2024 -0700

    update replica guidance (#1265)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 9d51d608b470ba94740f5b0ecc9c8d76813778e4[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed May 29 10:01:28 2024 -0400

    fix/update blog policy (#1254)
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ab923f62b858bb7504d8f51f1c26e401a8511cd5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed May 29 10:01:15 2024 -0400

    Render policies (#1253)
    
    * render latest policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * manually fix indentation
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2a59d77e0fbe37114c8d2fa2b0961a00b99d9898[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Wed May 29 17:45:09 2024 +0530

    feat: add apiserver storage object metric to reports-server blog (#1256)
    
    * feat: add apiserver storage object metric to reports-server blog
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * feat: add description for object count
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update index.md
    
    Co-authored-by: shuting <shutting06@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update index.md
    
    Co-authored-by: shuting <shutting06@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Co-authored-by: shuting <shutting06@gmail.com>

[33mcommit 4943d8f1e3cdb43a50bde43b4abf6a0f6f4d4e6e[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Tue May 28 21:39:46 2024 -0400

    chore(deps): bump actions/checkout from 4.1.4 to 4.1.6 (#1246)
    
    Bumps [actions/checkout](https://github.com/actions/checkout) from 4.1.4 to 4.1.6.
    - [Release notes](https://github.com/actions/checkout/releases)
    - [Changelog](https://github.com/actions/checkout/blob/main/CHANGELOG.md)
    - [Commits](https://github.com/actions/checkout/compare/0ad4b8fadaa221de15dcec353f45205ec38ea70b...a5ac7e51b41094c92402da3b24376905380afc29)
    
    ---
    updated-dependencies:
    - dependency-name: actions/checkout
      dependency-type: direct:production
      update-type: version-update:semver-patch
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit c54573fe1e00c5cbeb716a9b5409495202cfbfb4[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Wed May 29 06:52:42 2024 +0530

    fix: remove outdated note about image pull secret (#1240)
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit eccf3c7269c7dc44b86097c9e7144007109d2377[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Wed May 29 09:21:06 2024 +0800

    docs: add a warning related to pods/ephemeralcontainers in VAPs (#1239)
    
    * docs: add a warning related to pods/ephemeralcontainers in VAPs
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * Update content/en/docs/writing-policies/validate.md
    
    Minor styling.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5e4480de5a894ce704ad8ad0ff483f054cd1a3f6[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Wed May 29 06:42:14 2024 +0530

    feat(blog): introducing reports-server (#1218)
    
    * feat(blog): introducing reports-server
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * fix: add namespace create
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * feat: add testing number
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * fix: add details for reporting reports size
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * fix: update date
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/blog/general/introducing-reports-server/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit aff93bfd530a62f5fe3ecfbebfd1dac1486798ec[m
Author: Khaled Emara <khaled.emara@nirmata.com>
Date:   Thu May 23 16:11:10 2024 +0300

    fix(links): broken links (#1249)
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>

[33mcommit af8ea2e0eadf985148edd6ceaa726413591c468f[m
Author: shuting <shuting@nirmata.com>
Date:   Wed May 1 22:09:41 2024 +0800

    feat: update 1.12.1 scaling test results for the reports controller  (#1236)
    
    * feat: update scaling test results for the admission controller
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * feat: update scaling test results for the reports controller
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit a295be0db69af02f9444ea13a503eba455818db4[m
Author: shuting <shuting@nirmata.com>
Date:   Wed May 1 20:12:26 2024 +0800

    feat: update scaling test results for the admission controller (#1235)
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 9a3c1143ab70b6b48cf870dcb3fd8fa4690a3a6e[m
Author: shuting <shuting@nirmata.com>
Date:   Mon Apr 29 20:27:28 2024 +0800

    feat: add reports controller testing results  (#1221)
    
    * feat: add reports controller testing results
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * chore: add numbers
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 12bbfacfb82379555bb3fd695f91a69a3b977734[m
Merge: 12079c8f 4ae04708
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Mon Apr 29 09:36:22 2024 +0530

    update versions in main (#1231)

[33mcommit 4ae047081d963687607547590427bd8114784659[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Apr 28 21:04:43 2024 -0700

    update versions in main
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 12079c8f596907258fca128e568393ae8bbd7dca[m
Merge: 400422c2 d7501f01
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Mon Apr 29 09:19:19 2024 +0530

    fix blog date, and versions menu (#1228)

[33mcommit d7501f015a7c0eb9555188b3d0cb305e10c0f785[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Apr 28 20:43:10 2024 -0700

    fix blog date, and versions menu
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 400422c296c792bd2a21e1ac96ec822987c21645[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Fri Apr 26 16:21:29 2024 +0530

    fix: update grofers link to blinkit (#1226)
    
    fix(attempt): update grofers link to blinkit
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 8e4ad0f98e6c1f85eeae1265cf5c634b72607da7[m
Author: shuting <shuting@nirmata.com>
Date:   Fri Apr 26 18:35:10 2024 +0800

    feat: add 1.12 release blog (#1224)
    
    * feat: add 1.12 release blog
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * Update content/en/blog/releases/1-12-0/index.md
    
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * assertion tree example
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    Co-authored-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 8b7c0980eca7a68db0da22a81a20192ad05648e7[m
Merge: 1d7e6ce0 8b69b394
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Apr 26 12:26:51 2024 +0200

    feat: add docs about assertion trees in cli (#1223)

[33mcommit 8b69b394a284713ef149c8e8decbe0f2cfb5a086[m
Merge: c8b6c83a 1d7e6ce0
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Apr 26 10:36:59 2024 +0200

    Merge branch 'main' into assertion-trees

[33mcommit c8b6c83a8d02a3ab5a3f3afb19a64fb8e839c69d[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Apr 26 09:34:35 2024 +0200

    feat: add docs about assertion trees in cli
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 1d7e6ce07863488c99c4c9685499fb0bf99a7a20[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Fri Apr 26 15:39:54 2024 +0800

    Bump lycheeverse/lychee-action from 1.9.3 to 1.10.0 (#1222)
    
    Bumps [lycheeverse/lychee-action](https://github.com/lycheeverse/lychee-action) from 1.9.3 to 1.10.0.
    - [Release notes](https://github.com/lycheeverse/lychee-action/releases)
    - [Commits](https://github.com/lycheeverse/lychee-action/compare/c053181aa0c3d17606addfe97a9075a32723548a...2b973e86fc7b1f6b36a93795fe2c9c6ae1118621)
    
    ---
    updated-dependencies:
    - dependency-name: lycheeverse/lychee-action
      dependency-type: direct:production
      update-type: version-update:semver-minor
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit fc45f1411f1d7905b9266094455b74b74f9015f2[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Thu Apr 25 17:40:10 2024 +0800

    Bump actions/checkout from 4.1.2 to 4.1.4 (#1220)
    
    Bumps [actions/checkout](https://github.com/actions/checkout) from 4.1.2 to 4.1.4.
    - [Release notes](https://github.com/actions/checkout/releases)
    - [Changelog](https://github.com/actions/checkout/blob/main/CHANGELOG.md)
    - [Commits](https://github.com/actions/checkout/compare/9bb56186c3b09b4f86b1c65136769dd318469633...0ad4b8fadaa221de15dcec353f45205ec38ea70b)
    
    ---
    updated-dependencies:
    - dependency-name: actions/checkout
      dependency-type: direct:production
      update-type: version-update:semver-patch
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 0ebb56652ae6b187858f92ef6ea9c195d2d89838[m
Author: shuting <shuting@nirmata.com>
Date:   Tue Apr 23 22:30:09 2024 +0800

    Add 1.12 load testing data (#1217)
    
    * add 1.12 load testing data
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * update table
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * Update content/en/docs/installation/scaling.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * fix: formatting
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit a85c398b622f024eb4db6ef70d085be19d3666ca[m
Author: shuting <shuting@nirmata.com>
Date:   Wed Apr 17 15:46:00 2024 +0800

    feat: add new flags maxAuditWorkers, maxAuditCapacity (#1210)
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 5060f3dfeffc729787f5535f9a7ee2b5086f96a1[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 8 08:29:57 2024 -0400

    Refactor links (#1205)
    
    * check-links
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * new link hook
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * rename
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * start link refactoring
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * links
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * cli links
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * monitoring
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * tracing
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix yes link
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * check rendered links after unrendered links
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * 120 Netlify timeout
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * bump SLSA spec in links
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * deactivate for now
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * include nirmata.com
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * links
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * nits
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * nits
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * nits
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * links
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * optimize
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * note about building links
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * note expand
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * links
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit d8d0738841f5de9f816946f27e84d74ad94d687a[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Wed Apr 3 13:43:14 2024 +0800

    Bump peaceiris/actions-hugo from 2.6.0 to 3.0.0 (#1207)
    
    Bumps [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo) from 2.6.0 to 3.0.0.
    - [Release notes](https://github.com/peaceiris/actions-hugo/releases)
    - [Changelog](https://github.com/peaceiris/actions-hugo/blob/main/CHANGELOG.md)
    - [Commits](https://github.com/peaceiris/actions-hugo/compare/16361eb4acea8698b220b76c0d4e84e1fd22c61d...75d2e84710de30f6ff7268e08f310b60ef14033f)
    
    ---
    updated-dependencies:
    - dependency-name: peaceiris/actions-hugo
      dependency-type: direct:production
      update-type: version-update:semver-major
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 507ce70c122ce8b46e82eb3bbff771fc67ad04e1[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Mar 31 08:04:07 2024 -0400

    1.12 misc updates (#1204)
    
    * add cleanupServerPort flag
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * helm change notes
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * bump ver
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * generalize
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * note
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * increase Netlify preview wait
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit df48a6ec0ab24bffdbd291c2a33636384c01c887[m
Author: Khaled Emara <khaled.emara@nirmata.com>
Date:   Sat Mar 30 02:22:50 2024 +0200

    doc(flag): add maxAPICallResponseLength flag (#1201)
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>

[33mcommit a9ae27ec0ab715f1d1f340af2030de945ec16bcf[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Mar 24 06:42:36 2024 -0400

    remove schedule from link checker (#1199)
    
    remove schedule
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 273e7680aa47f8011d0d77bde8225957213c9616[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Mar 15 10:00:08 2024 -0400

    Update gce note (#1194)
    
    update gce note
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 6ca36abff05dfde0301970aae63f4eb7c7976e17[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Mar 14 08:43:12 2024 -0400

    add instructions for accessing earlier docs (#1192)
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 1de7aaddfa246922ef277e989f26e15a4449cf50[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Mar 14 08:29:02 2024 -0400

    Compatibility updates (#1190)
    
    updates
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 710852a4f4849da9f651e4995e46bf18957c9684[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Mar 14 07:43:05 2024 -0400

    add 1.12 to menu (#1188)
    
    * add 1.12 to menu
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * update lycheeignore
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 3dbca0672a82fa7665df0e8ab18ff10fdba46c7f[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Wed Mar 13 12:02:05 2024 -0400

    Bump actions/checkout from 4.1.1 to 4.1.2 (#1186)
    
    Bumps [actions/checkout](https://github.com/actions/checkout) from 4.1.1 to 4.1.2.
    - [Release notes](https://github.com/actions/checkout/releases)
    - [Changelog](https://github.com/actions/checkout/blob/main/CHANGELOG.md)
    - [Commits](https://github.com/actions/checkout/compare/b4ffde65f46336ab88eb53be808477a3936bae11...9bb56186c3b09b4f86b1c65136769dd318469633)
    
    ---
    updated-dependencies:
    - dependency-name: actions/checkout
      dependency-type: direct:production
      update-type: version-update:semver-patch
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 27458f897cebba04c3df92e8840711333289e1a3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Mar 13 11:58:40 2024 -0400

    Check links on PR; fix links (#1185)
    
    * check links on PR
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix base
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * new base
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * base as /content/en/docs/
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * base as /content/en/
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * base as https://kyverno.io
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * try with hugo building
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * npm install
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * use github token
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * use value
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * ignore rendered policies
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * glob
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * use lychee.toml
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * try
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * try
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * remove .lycheeignore
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * try new path to -c
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * try
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * simplify
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add back .lycheeignore
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix two links
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * simplify
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fixes
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * link fixes
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix links after CLI reorg
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * test
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * try
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix more links
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * use jakepartusch/wait-for-netlify-action@v1.4
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * update
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * reorder
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * enable Dependabot for Actions
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 040b1afdefe8ac7bff60563afd66af37b19d9711[m
Author: shuting <shuting@nirmata.com>
Date:   Wed Mar 13 20:35:55 2024 +0800

    feat (generate): add orphanDownstreamOnPolicyDelete to preserve downstream on policy deletion  (#1133)
    
    * update docs
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * format
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ebecee0b73c01767fd20bee87383e01d732adb7d[m
Merge: 799b07e1 807d8e54
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Mar 13 04:51:08 2024 -0400

    Reorder `sha256()` filter (#1184)

[33mcommit 807d8e543d2100328f38902388a050d35a0cfefc[m
Merge: c3f56cdb 799b07e1
Author: shuting <shuting@nirmata.com>
Date:   Wed Mar 13 16:50:57 2024 +0800

    Merge branch 'main' into global-context

[33mcommit 799b07e124aefc0f64de201c540ba35d48b02694[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Mar 13 04:50:16 2024 -0400

    Render policies (#1181)
    
    render
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit c3f56cdbd17c16094e90ca2f0e1f3594307db59b[m
Merge: 7ddf4870 1c160fe0
Author: chipzoller <chipzoller@gmail.com>
Date:   Tue Mar 12 10:29:29 2024 -0400

    Merge branch 'main' into global-context

[33mcommit 7ddf48703c39d9d4b7584106ed2a14cde4271a10[m
Author: chipzoller <chipzoller@gmail.com>
Date:   Tue Mar 12 10:27:27 2024 -0400

    reorder
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 1c160fe09e3013fd8f0cb4285378c1f8441e164c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Mar 12 10:25:16 2024 -0400

    Update global context docs (#1183)
    
    update global context
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit f7a0553d8cc8aa41ec46482a9b02954c73db3cd1[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Mar 12 15:14:57 2024 +0100

    refactor: kyverno cli section (#1180)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 4932e052d7dc99bd90a2b602eac200e6d8d80bfb[m
Author: chipzoller <chipzoller@gmail.com>
Date:   Tue Mar 12 10:08:34 2024 -0400

    update global context
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 92b7e3cda3ff289319dd4e9e6d39b7e143ac4828[m
Author: Khaled Emara <khaled.emara@nirmata.com>
Date:   Tue Mar 12 14:21:09 2024 +0200

    feat: add global context documentation (#1126)
    
    feat: add globalcontext documentation
    
    Signed-off-by: Khaled Emara <khaled.emara@nirmata.com>

[33mcommit 7474b30960a75266cdc5cbae1303d92c36858746[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Mar 11 02:45:56 2024 -0400

    Add troubleshooting note; etc. (#1178)
    
    * add note
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix sentence on resource filters
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * Documents `--webhookServerPort` flag
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * tweak
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * fix link
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 878d16d2297abd31cb9adf8f136355a0bd2f0e0f[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Sun Mar 10 22:53:48 2024 +0100

    refactor: reorganise cli docs (#1179)
    
    * refactor: cli docs
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * ref docs
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    ---------
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 95a09f3d33658ba139714a531c86e8c5a54755e3[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Fri Mar 8 17:45:31 2024 +0200

    add docs for exception enhancements (#1157)
    
    * add docs for exception enhancements
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * Update content/en/docs/Writing policies/exceptions.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/docs/Writing policies/exceptions.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * fix: add the usecase of service mesh
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * fix
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * Update content/en/docs/Writing policies/exceptions.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 21035505bf5433c2bceffde5d0e789240f6a1603[m
Author: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
Date:   Fri Mar 8 18:37:06 2024 +0530

    inital changes for docs regarding dyn operations (#1134)
    
    * inital changes for docs regarding dyn operations
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    * add note for no opn specified
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    * update notes for webhookconf
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    * update location for dyn webhook info
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    ---------
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 569c268d2dd745ed00048b493d2ffddad3eec51b[m
Author: shuting <shuting@nirmata.com>
Date:   Thu Mar 7 22:34:58 2024 +0800

    feat: add docs for policy based matchConditions (#1119)
    
    * add docs for policy based matchConditions
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * address comments
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5ba08bcee60a5037a6352d4da738904b58007b23[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Thu Mar 7 15:56:16 2024 +0200

    fix minor bugs in the pod security exemption section (#1156)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 672e6810353fb332aa250b8582773138d5f86828[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Thu Mar 7 15:54:48 2024 +0200

    add docs for supporting bindings in the CLI and reports (#1152)
    
    * add docs for supporting bindings in the CLI
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * add docs for supporting bindings in the reports
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * docs: add binding in the CLI test
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Co-authored-by: shuting <shuting@nirmata.com>
    Signed-off-by: Mariam Fahmy <mariamfahmy66@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Co-authored-by: shuting <shuting@nirmata.com>
    Signed-off-by: Mariam Fahmy <mariamfahmy66@gmail.com>
    
    ---------
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Signed-off-by: Mariam Fahmy <mariamfahmy66@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit a40ff4527815520a05cb6e9b69d857fd5a0d2e36[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Mar 5 02:30:15 2024 -0500

    Misc fixes (#1175)
    
    * update sample
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * clarify use of `log_backtrace_at` container flag
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * clarify auth for registry
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * clarify GVK
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * better tip
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * better troubleshooting
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * clarify results[].policy format
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 9693798603a53457927382cb868bcb44d9d9ee21[m
Author: Shubham Singh <shubhammahar1306@gmail.com>
Date:   Sat Mar 2 21:45:48 2024 +0530

    `reference` variable value corrected. (#1176)
    
    changing the incorrect digest example
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>

[33mcommit c3e8e2b8536e2b24d48407b64a2d0c813b3dc859[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Mar 2 07:19:59 2024 -0800

    Mutate argocd (#1153)
    
    * cleanup deleted policies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * add ArgoCD SSA
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 296cb8a9bd11514cb3f3fd029d6c2bbc4f3e191b[m
Author: Shubham Singh <shubhammahar1306@gmail.com>
Date:   Sat Mar 2 20:49:05 2024 +0530

    [Enhancement] documenting the images variables, `reference` and `referenceWithTag` (#1162)
    
    added docs for reference and referenceWithTag fields
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ab8b0845d36e1e2288594d1a3c493db36130dd66[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Mar 2 10:16:10 2024 -0500

    Docsy fixes (#1174)
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 70c03b13caaac6b3efb1ede65156df524a9029c9[m
Author: Suruchi Kumari <suruchikumarimfp4@gmail.com>
Date:   Thu Feb 29 17:35:03 2024 +0530

    Updated imageRegistryCredentials.secret to  imageRegistryCredentials.secrets (#1171)
    
    updated imageRegistryCredentials.secret to secrets
    
    Signed-off-by: GitHub <noreply@github.com>

[33mcommit dec02a4059b20b619471a4ae6539c89aa87f91df[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Mon Feb 26 14:10:51 2024 +0200

    add a blog for generating VAPs (#1151)
    
    * add a blog for generating VAPs
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * fix
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * fix: update the blog date
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    ---------
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>

[33mcommit fc04b8707594cfa0ba839cd76bde6fbfa1620a9a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 23 07:41:44 2024 -0500

    [Blog] Assigning Node Metadata to pods (#1161)
    
    * add blog
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * tweak
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 6f965cae97d6ef0c7d74ea2d62b031b2b57e45b9[m
Author: Suruchi Kumari <suruchikumarimfp4@gmail.com>
Date:   Fri Feb 23 15:19:41 2024 +0530

    [Enhancement] add new flag loggingtsFormat (#1168)
    
    change default value to RFC3339
    
    Signed-off-by: GitHub <noreply@github.com>

[33mcommit 42f991b331d606a0aec3ba551dc931ffa7194a93[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Feb 19 06:56:47 2024 -0500

    Extend Admission Controllers 101 (#1155)
    
    extend
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit c6c2528b0c3c9c418db4e74b94b34db573e97e00[m
Merge: c31b070e 6421a3cb
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Feb 15 14:28:23 2024 +0100

    blog: add chainsaw v0.1.4 blog post (#1158)

[33mcommit 6421a3cb9272550d141deca2eb96b60ceef245e4[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Feb 15 11:01:13 2024 +0100

    blog: add chainsaw v0.1.4 blog post
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit c31b070e1d9305593c79845f8ecd619a89e36816[m
Author: Shubham Singh <shubhammahar1306@gmail.com>
Date:   Sat Feb 10 17:37:33 2024 +0530

    Admission Controllers 101 Docs (#1086)
    
    * A Guide to Kubernetes Admission Controllers
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * A Guide to Kubernetes Admission Controllers
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * correction #1
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * correction 2
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * correction 3
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * correction 4
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * added more usecases
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * edited 'Multi-tenancy'
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * edited 'Supply chain security'
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * removed some use cases
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * Fined-grained RBAC:
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * Fined-grained RBAC:
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    ---------
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 863894d962858fa39b0ab47d948780f5e1fd69e6[m
Author: Sanskar Gurdasani <92817635+Sanskarzz@users.noreply.github.com>
Date:   Thu Feb 8 17:18:24 2024 +0530

    [1.12] Added docs for policy exceptions support in the CLI. (#1137)
    
    * added docs for test command
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * added docs for apply command
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    suggested changes
    
    Co-authored-by: Mariam Fahmy <mariamfahmy66@gmail.com>
    Signed-off-by: Sanskar Gurdasani <92817635+Sanskarzz@users.noreply.github.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    updated suggested changes
    
    Co-authored-by: Mariam Fahmy <mariamfahmy66@gmail.com>
    Signed-off-by: Sanskar Gurdasani <92817635+Sanskarzz@users.noreply.github.com>
    
    * added applypolicyexception section
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * mentioning  shorthand letter with --exception flag
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    
    ---------
    
    Signed-off-by: Sanskarzz <sanskar.gur@gmail.com>
    Signed-off-by: Sanskar Gurdasani <92817635+Sanskarzz@users.noreply.github.com>
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: Mariam Fahmy <mariamfahmy66@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 191d47e6c86800715e783c1a9ad79051651294ac[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Feb 5 19:03:03 2024 -0500

    [Blog] Securing Services Meshes Easier with Kyverno (#1143)
    
    * init
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add post
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit c71a0cb0ac606d1cb39a6e8a18a0a675f65cc427[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Tue Feb 6 01:30:12 2024 +0200

    [1.12] add `--protectManagedResources` flag to the cleanup controller (#1140)
    
    add --protectManagedResources flag to the cleanup controller
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6b49b577c9acada29676311124e26f2d58708df2[m
Author: Gurmannat Sohal <95538438+itsgurmannatsohal@users.noreply.github.com>
Date:   Sun Feb 4 21:03:49 2024 +0530

    [1.12] Documentation for Pod Security Admission Integrations (#1037)
    
    documentation for Pod Security Admission Integrations
    
    Signed-off-by: Gurmannat Sohal <iamgurmannatsohal@gmail.com>
    Signed-off-by: Gurmannat Sohal <95538438+itsgurmannatsohal@users.noreply.github.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit db4382a5d0b15df3e8626c057cc257da447502e7[m
Author: M Viswanath Sai <110663831+mviswanathsai@users.noreply.github.com>
Date:   Sun Feb 4 19:59:14 2024 +0530

    [1.12] Add `--loggingtsFormat` flag (#1077)
    
    Update customization.md to include loggingtsFormat flag
    
    Signed-off-by: M Viswanath Sai <110663831+mviswanathsai@users.noreply.github.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f9e97963f8126fc554b0af0b99cbd4f8ecbd34b3[m
Author: Brandon T. Lim <blim747@gmail.com>
Date:   Sun Feb 4 05:53:58 2024 -0800

    Update OOM Troubleshooting guide with pending requests and permissions recommendations (#1138)
    
    * Update OOM Troubleshooting guide with pending requests and permissions recommendations
    
    Signed-off-by: Brandon Lim <blim747@gmail.com>
    
    * Update content/en/docs/Troubleshooting/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Brandon Lim <blim747@gmail.com>
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b851464b87e361bcf63613f7ab3012585d1f1542[m
Merge: 18124e20 e142686a
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Fri Feb 2 12:33:03 2024 +0200

    [1.12] feat(configuring-kyverno): add webhook scope explanation (#1139)

[33mcommit e142686aa3f8e23a529cd46abee262b8e23bec09[m
Author: Florian Hopfensperger <florian.hopfensperger@allianz.de>
Date:   Fri Feb 2 08:40:17 2024 +0100

    feat(configuring-kyverno): add webhook scope explanation
    
    Signed-off-by: Florian Hopfensperger <florian.hopfensperger@allianz.de>

[33mcommit 18124e2044b5ccc2806bdb8dde3860e515a8a21e[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jan 31 11:04:09 2024 -0500

    set x-frame-options (#1122)
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit a148c2e06e760ed2576ce53edcbb56efc5c232e7[m
Author: kanha gupta <92207457+kanha-gupta@users.noreply.github.com>
Date:   Wed Jan 31 18:21:41 2024 +0530

    [1.12] Add JMESPath `sha256` documentation (#1065)
    
    jmespath SHA256 documentation
    
    Signed-off-by: Kanha gupta <kanhag4163@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 61279fa3c16363cfbf147fa704a314a3ebc39677[m
Author: Khaled Emara <KhaledEmaraDev@gmail.com>
Date:   Wed Jan 31 14:50:47 2024 +0200

    [1.12] chore: add new events client container flags (#1099)
    
    chore: add new events client container flags
    
    Signed-off-by: Khaled Emara <mail@KhaledEmara.dev>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 447b9c35a50e1fb59845496d5674aa1316b7f3f7[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Jan 30 23:20:10 2024 -0500

    Misc. updates (#1132)
    
    * move and adjust is_external_url
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add --renewBefore flag
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit b42ba55c3fd91199c7d569b2f5adeed8f21c6914[m
Author: dreamjz <25699818+dreamjz@users.noreply.github.com>
Date:   Wed Jan 31 08:47:03 2024 +0800

    [1.12] update `time_parse` filter (#1070)
    
    * docs(jmespath): update time_parse doc
    
    Signed-off-by: dreamjz <25699818+dreamjz@users.noreply.github.com>
    
    * insert new lines
    
    Signed-off-by: dreamjz <25699818+dreamjz@users.noreply.github.com>
    
    ---------
    
    Signed-off-by: dreamjz <25699818+dreamjz@users.noreply.github.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f13a12beae5536b41ef031797b3a52f27fda0117[m
Author: UgOrange <lichanghao.orange@bytedance.com>
Date:   Wed Jan 31 08:43:40 2024 +0800

    [1.12] feat: add IsExternalURL doc (#982)
    
    * feat: add IsExternalURL doc
    
    Signed-off-by: lichanghao.orange <lichanghao.orange@bytedance.com>
    
    * Update content/en/docs/Writing policies/jmespath.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Writing policies/jmespath.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Writing policies/jmespath.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Writing policies/jmespath.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Writing policies/jmespath.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Writing policies/jmespath.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: lichanghao.orange <lichanghao.orange@bytedance.com>
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 234d5f4f5cf9ac2e79c4abcd5da45f266d42895d[m
Author: Zadkiel Aharonian <zadkiel.aharonian@gmail.com>
Date:   Wed Jan 31 01:37:08 2024 +0100

    [1.12] feat: add configmap webhookLabels (#1018)
    
    feat: add configmap webhookLabels
    
    Signed-off-by: Zadkiel Aharonian <hello@zadkiel.fr>
    Signed-off-by: Zadkiel Aharonian <zadkiel.aharonian@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b91337a8d0d2c6a7eae109ddf25d5a04ff63b396[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Jan 30 19:34:45 2024 -0500

    Misc. updates (#1130)
    
    * add generate with clone warning note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add Argo CD platform note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2600b08f99411ef71db8dc4f29bd81cd82c7c0e4[m
Author: Anusha Hegde <anusha.hegde@nirmata.com>
Date:   Tue Jan 30 16:01:59 2024 +0100

    Update Enterprise Kyverno link (#1127)
    
    Update the docs link for Enterprise Kyverno Release Compatibility Info
    
    Signed-off-by: Anusha Hegde <anusha.hegde@nirmata.com>

[33mcommit fa30381d32f4f597236abc22286802041539f91f[m
Author: M Viswanath Sai <110663831+mviswanathsai@users.noreply.github.com>
Date:   Tue Jan 30 03:42:47 2024 +0530

    Update validate.md (#1120)
    
    Removed data in Deny Rules section that is no longer accurate.
    
    Signed-off-by: M Viswanath Sai <110663831+mviswanathsai@users.noreply.github.com>

[33mcommit d6efa6c8f60d7dfed2c51167e5ca159ea80f8aed[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Jan 23 10:31:24 2024 -0500

    render policies (#1117)
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 9862458290f11b1c48d0603d43eec176e25a4382[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Tue Jan 23 20:02:50 2024 +0530

    [1.12] skipImageReferences in verify image policies (#1116)
    
    * feat: document skipImageReferences in verify image polices
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * fix: make it h3
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * fix: update policy
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/docs/Writing policies/verify-images/sigstore/_index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ea9672823019826edc93fd3794de8f4ab385204b[m
Author: Shubham Singh <shubhammahar1306@gmail.com>
Date:   Thu Jan 18 09:43:09 2024 +0530

    added fuzzing and 3rd party security audit links to the Security section of the docs (#1111)
    
    * added security audits section
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * suggestion for Jim 1
    
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * suggestions by Jim 2
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    
    * Update content/en/docs/security/_index.md
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * Update content/en/docs/security/_index.md
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * Update content/en/docs/security/_index.md
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit b669c0fd41f4a1a43961f51892bf072e400cea8a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jan 17 08:40:57 2024 -0500

    Update `imagePullSecrets` flag description (#1112)
    
    Update flag description
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit e954116917e7cb71b99a493fe29096ce3878cd00[m
Author: Shubham Singh <shubhammahar1306@gmail.com>
Date:   Tue Jan 16 11:14:29 2024 +0530

    Fixed a grammatical mistake (#1108)
    
    grammatical mistake
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>

[33mcommit 2a7f33f954d86b603cba54ef8140a8a1ee2c1e0c[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jan 15 08:13:21 2024 -0800

    render policies (#1103)
    
    * render policies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * cleanup deleted policies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 7c7a2c8cd3ec6635039d975858592d6003243334[m
Author: Weru <fromweru@gmail.com>
Date:   Wed Jan 3 14:33:59 2024 +0300

    Update Docsy Theme to 0.8.0 (#1030)
    
    * update docsy v0.7.0 > v0.8.0
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * restore upstream module state
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * restore go version
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * Update config/_default/params.toml
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Weru <fromweru@gmail.com>
    
    ---------
    
    Signed-off-by: weru <fromweru@gmail.com>
    Signed-off-by: Weru <fromweru@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4a43374ac719bc94cf3ec55f25049eb26f17cedc[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Jan 2 16:56:10 2024 +0100

    chore: bump a couple of deps (#1098)
    
    * chore: bump a couple of deps
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    ---------
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit de21eed33ec77e59441e281a602c9c1b7cf186e2[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Jan 2 16:24:25 2024 +0100

    fix: merge go mod (#1095)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 034f88a422fc3a5546627811b05aaefd18a0492d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Jan 2 00:21:35 2024 -0500

    Updates (#1092)
    
    * security updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note on ClusterRole permissions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 6ac331b0f700ae107748aea82a2c4bb102a65253[m
Author: shuting <shuting@nirmata.com>
Date:   Sat Dec 30 20:58:38 2023 +0800

    chore: add UpdateRequests reconciliation details (#1066)
    
    * add ur retry logic
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * Update content/en/docs/Writing policies/generate.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * add new spec attribute
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 553973276bad018be5053f9625b84c0c67268261[m
Author: shuting <shuting@nirmata.com>
Date:   Sat Dec 30 20:53:16 2023 +0800

    Clarify mutate existing force reconciliation (#1078)
    
    clarify force reconciliation
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 44e92e329b6e5aff507fa03040b7b82eed7fdb9e[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Sat Dec 30 07:52:30 2023 -0500

    Bump github.com/go-git/go-git/v5 from 5.2.0 to 5.11.0 in /render (#1084)
    
    Bumps [github.com/go-git/go-git/v5](https://github.com/go-git/go-git) from 5.2.0 to 5.11.0.
    - [Release notes](https://github.com/go-git/go-git/releases)
    - [Commits](https://github.com/go-git/go-git/compare/v5.2.0...v5.11.0)
    
    ---
    updated-dependencies:
    - dependency-name: github.com/go-git/go-git/v5
      dependency-type: direct:production
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 6993d07a1e7a6a0b5de90d52163a868ab75f287a[m
Author: Shubham Singh <shubhammahar1306@gmail.com>
Date:   Thu Dec 28 17:53:57 2023 +0530

    typo fix: `userServerSideApply` changed to `useServerSideApply` (#1085)
    
    Signed-off-by: Shubham Singh <shubhammahar1306@gmail.com>

[33mcommit 2c0b07c29e414115127bd301d59d9a8c472b83ff[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Dec 19 15:18:53 2023 -0800

    add validatingAdmissionPolicyReports flag (#1075)
    
    * add validatingAdmissionPolicyReports flag
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * add a note in the reports section
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * Update content/en/docs/Writing policies/validate.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Mariam Fahmy <mariamfahmy66@gmail.com>
    
    ---------
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Signed-off-by: Mariam Fahmy <mariamfahmy66@gmail.com>
    Co-authored-by: Mariam Fahmy <mariamfahmy66@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4e22593b7a3cddde0aa0660588c328cfafc163cb[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 19 17:45:56 2023 +0100

    fix: search (#1067)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit a4f5635c782c70adb0c7beb37e4f5c4d28c09f14[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Dec 19 09:27:35 2023 -0500

    Render policies (#1071)
    
    render
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 32cfed94df92995f6064444abf6dbba04312fabf[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 19 15:27:22 2023 +0100

    fix: remove log when rendering policies (#1072)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 5ea0fa18dbe1aeecd440e3f48a1fa2d73647bd7e[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Dec 18 20:10:52 2023 -0800

    merge ValidatingAdmissionPolicy docs into Validate rule and CLI (#1068)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit d7728f2ab232bb63a5b07c23cb4451331f094c76[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Fri Dec 15 15:29:50 2023 +0200

    chore: create a table for the container flags (#1060)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bef67369b3e201f7e38f2141a447b0a95a3c0ff0[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Fri Dec 15 15:23:25 2023 +0200

    modify VAP docs (#1058)
    
    * modify VAP docs
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * Update content/en/docs/Writing policies/validating-admission-policies/generate-validating-admission-policies.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Mariam Fahmy <mariamfahmy66@gmail.com>
    
    ---------
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Signed-off-by: Mariam Fahmy <mariamfahmy66@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit a99befe9735e1cf72df0c10390f18f04814d043f[m
Merge: 769b5071 ce2331bc
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Dec 15 12:06:33 2023 +0100

    chore: add another Chainsaw blog (#1053)

[33mcommit ce2331bc26ecc53c6e5cf05866139bb96618526d[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Dec 15 10:34:17 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 31892ac32f2a10d201567b9de4648571bb11eef7[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Dec 15 10:34:10 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit e3cfb6b2ccdeb9efb90b45ab39035369e7f716cb[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Dec 15 08:56:54 2023 +0100

    title
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 35f49c8a18e510e936b895ef555e98f70f10dd28[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Dec 15 00:01:18 2023 +0100

    comment
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 667438dd5ba8cc5b36981b4b4098fa3cd8380fbe[m
Merge: bde318f2 769b5071
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 23:18:14 2023 +0100

    Merge branch 'main' into chainsaw-blog-2

[33mcommit bde318f28de4baa3e6214acc920f5e80f183aed2[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:48:54 2023 +0100

    what more
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 9cda410bac5c9408821a63fb3faeacd06170a89e[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:46:10 2023 +0100

    small nit
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit bcd9fc58400126055e66138df6eb53aacb60ce7b[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:37:59 2023 +0100

    title
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 3b6cf1765c56995f6ec01df46e4d9f910429a2e6[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:36:00 2023 +0100

    assertion check explained
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit ed3ea279aff18ff7c35c46bd2f882a169d1cb2af[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:27:18 2023 +0100

    playground
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 3b6b5c3e0df725e1ec6f1b0dba9310faa39bc669[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:17:52 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 924fd10f353e1778bf987625bc4fd198e7cdf148[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:17:21 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 6b91f0f537b5e7126c4158dd64476d87b1d35368[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:17:01 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 2a6e7de558ea43672e5868ab9a1177d4b657b1b1[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:16:47 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 280e81c31788f1f9b1c567cd601f344d41c6128c[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:16:28 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 04a7338797988a4e126f26ed0fb1dcad0a616df2[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:16:11 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 99c74dc507145a58a002433ac6d859d0739a5c8f[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:15:26 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit ae8dbbe06ea3be472c9d21dc518e7685a826447d[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:15:08 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit a630e7409f957d7adbe676d5a17b4a77cab90f4e[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:14:48 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit cc015cb8f3b7588b05d05dafdee18be8ff085e74[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:14:34 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 3e88f456673033162bc5b0c9345a5288376ee59e[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:14:07 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 4f243409336983dcf0609e12bc0e87ad0786b8b4[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:13:53 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit a0900e4b01150bf304d52aff5dee76f5d0996cb6[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:13:47 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 54dee602e592e2fbc5d9ef171fffa6a92570df75[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:13:41 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit f00297210b7f2c2838ceea998f03c3c333ff8554[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:13:22 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 0bc887028689adfdb9648e57f86ced627e0c2204[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:12:27 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit e79b12f374f819324ada50a20d1f1819995e51a8[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:12:18 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 769b5071a9a46f72dc1e19bbf6c50522fef512b2[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Thu Dec 14 22:02:27 2023 +0100

    fix: render cleanup policies (#1057)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit bb2fffc38b5bacda510be56d2b9c753844b3f34e[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 14 10:12:49 2023 -0500

    Render policies (#1054)
    
    * render
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * force policyType
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit be26ebba458cc1ac17cb9bfbd411bd5df584b148[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 13 19:09:57 2023 +0100

    mend
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 05520c163afe576e0056bff4b0e45067facc9cf8[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 13 18:54:34 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit f437b7a66a4f84d5b579dfcc247ae0a0876efeb3[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 13 18:54:13 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 6ca0c82dc0d46c35e8e1d00d72aedf8a1dccfa3b[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 13 18:54:06 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit a3e89fb07a90a75fa8f2e60fbfd3e7a95bb598c9[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 13 18:54:00 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 95f23db01c4b540bddd4dee520936e576ffa125b[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 13 18:53:54 2023 +0100

    Update content/en/blog/general/why-chainsaw-is-unique/index.md
    
    Co-authored-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit d097d340d87ab69d06e4562d70f883863f37fa05[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 13 18:16:26 2023 +0100

    chore: add another Chainsaw blog
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit fcc2b93b119c7d4b4e26367ec671d71bd52b1621[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Dec 12 10:49:48 2023 -0500

    Fixes (#1050)
    
    * update manifest link; formatting
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * readme link
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * remove line numbers
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * upgrade clarifications
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit adba1b3984e93ee4b9598d38c40cc2e7e0a14724[m
Merge: d0301a67 e0623232
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 16:13:16 2023 +0100

    chore: add chainsaw blog (#1049)

[33mcommit e06232328c78c91f3152d499cf50d9b6c04da6ab[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 16:07:36 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 01a9806e30e95761cfb752bf7ff3cd643a9c1e0c[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 16:07:25 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit bd8e640e5eca3c792fdc4e292365fc72c7251ae6[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 16:07:15 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 444f3ce1a11609a847025cf4bdf8f6f273027d90[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:07:04 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit bda5ff2b7ffbc7db77369ce27067b2807b8c9028[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:06:44 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit f091026279fab150646e18917350bbde2bb1a728[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:06:26 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit c175508bb989175a8351488b1d7381868a861ca8[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:06:11 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 08ccd1f17642c4c7c67a13169e589815ba5b971b[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:05:49 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit f9bd2e598396518d15bd935d4c995e4d784d0aa9[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:05:41 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 8a616b5b0df8c7491af1df3a71f1c6c661f3ee1b[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:05:30 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 514ca83ea22a142316d288c6f135b1cd50beb814[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:05:19 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 9554e2b9652259f01759da0835edbaa714456911[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:05:09 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit e23be2987a9f69336379db16e7c557cad84e9ab5[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:04:41 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 13664641cbf335ea7499d442d34480d0ac380a65[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:04:25 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit ef2ebd6f09238ca76b786069fb5f3f46044cbac2[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:03:53 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit cc0f9abf7e329fdd973808716d82ab73ef563d48[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:03:48 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit b0bc09db541110b41839a2ec63fc24ea7f23224e[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:03:41 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 8a80cf93ac313f48721dbf9146d5b6ed518634a6[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:03:26 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit e7d3162dc653ffaa2d952419144fcd2957babb28[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 15:03:18 2023 +0100

    Update content/en/blog/general/introducing-chainsaw/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 8899cba59ce9101d5f32ac693e0675789b6024bd[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 12 14:01:39 2023 +0100

    chore: add chainsaw blog
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit d0301a67bcd85ed774e44360577f468a8caaa0c5[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon Dec 11 22:50:30 2023 +0100

    fix: update reports docs (#1045)
    
    * fix: update reports docs
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * report
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * list reports
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * Update content/en/docs/Policy Reports/examples.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * Update content/en/docs/Policy Reports/examples.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * Update content/en/docs/Policy Reports/_index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * review
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    ---------
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 8cac7729e5e69029e2b2a230c059e5b462e99b56[m
Author: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
Date:   Thu Dec 7 05:54:55 2023 +0530

    Add docs for fix command (#1031)
    
    * Add docs for fix command
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    * Add new line
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    ---------
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 0088b75cd71b0b9a51133a0d95adf50b8fb679c8[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 6 14:21:56 2023 +0100

    chore: add makefile (#1038)
    
    * chore: add makefile
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * rm old content
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    ---------
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 0554b78f59d64d8830a8f36cff5ab0cef108de8d[m
Merge: 43a4489a 514606e2
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 6 14:00:11 2023 +0100

    chore: add cherry pick bot (#1043)

[33mcommit 514606e2de38c2c9a4ecdafdf6e3794475e18df5[m
Merge: a48654cc 43a4489a
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Dec 6 07:59:16 2023 -0500

    Merge branch 'main' into cherry-pick-bot

[33mcommit a48654cc06d742a8d80ffb7f4cf6a07d773cc478[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 6 13:56:18 2023 +0100

    chore: add cherry pick bot
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 43a4489ab00060883284fdacb9d439464572cb05[m
Author: Mariam Fahmy <mariam.fahmy@nirmata.com>
Date:   Wed Dec 6 14:14:34 2023 +0200

    chore: move VAP docs into the Writing policies section (#1039)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>

[33mcommit 177188306537ae5e6a9df3fec0bf1f3bece03871[m
Merge: ada4e93c 0cdaa5a0
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 6 09:58:10 2023 +0100

    chore: render policies (#1036)

[33mcommit 0cdaa5a00a53c002bb42c551dde1699fba4588e5[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 6 08:41:55 2023 +0100

    chore: render policies
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit ada4e93cf086081cfe76bb915d58887c8f5ca0de[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Dec 3 11:39:24 2023 -0800

    update to v1.11.0 (#1032)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit e3cf557275cf6a29040b24935a1e2c21b312bc38[m
Author: Mariam Fahmy <mariam.fahmy@nirmata.com>
Date:   Fri Dec 1 17:38:44 2023 +0200

    add 1.11 to the compatability matrix (#1029)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>

[33mcommit 9d2f52c17ba105984a7491b8192290ad179c10c6[m
Author: Mariam Fahmy <mariam.fahmy@nirmata.com>
Date:   Fri Dec 1 16:07:27 2023 +0200

    add a blog for the usage of CEL in Kyverno policies (#1004)
    
    * add a blog for the usage of CEL in Kyverno policies
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * Update content/en/blog/general/using-cel-expressions-in-kyverno-policies/index.md
    
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * fix
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    ---------
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f98899a9fe531f3b328e7f20f9b41caf0867c289[m
Author: shuting <shuting@nirmata.com>
Date:   Fri Dec 1 21:54:43 2023 +0800

    feat: add ttl cleanup metrics (#1027)
    
    add ttl cleanup metrics
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit caa85533cae86c2b373fc8d2185191abdd185541[m
Author: Mariam Fahmy <mariam.fahmy@nirmata.com>
Date:   Fri Dec 1 15:31:51 2023 +0200

    add docs for validate.cel subrule (#1005)
    
    * add docs for validate.cel subrule
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * add docs for generating VAPs
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * fix
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * add autogen
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * refer to the CLI docs
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    ---------
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 3a76427163f4d68761bdc3d434ae24252c9aef74[m
Author: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
Date:   Fri Dec 1 18:49:52 2023 +0530

    Cli doc enhancement for new commands (#1012)
    
    * Documentation for new flag
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    * Documentation for docs command
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    * Documentation for create command
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    * Update content/en/docs/Kyverno CLI/_index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    
    * Arrange new sections in alphabetical order
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    * Add explanation for each item in create subcommand
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    * Add output in all examples
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    
    ---------
    
    Signed-off-by: anushkamittal2001 <anushka@nirmata.com>
    Signed-off-by: Anushka Mittal <138426011+anushkamittal2001@users.noreply.github.com>
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 1f061771f020374fa8e86e43ee2f1c18d6f457f5[m
Merge: c54d92c9 51b399ff
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Fri Dec 1 18:36:38 2023 +0530

    feat: add docs for cosign 2.0 enhancements (#992)

[33mcommit 51b399ff5f7bfded5607f964cea815953884f632[m
Merge: 5548e29b c54d92c9
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Fri Dec 1 18:33:54 2023 +0530

    Merge branch 'main' into cosign-new-docs
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit c54d92c9a9ef0438cebb9e00f610fc4c050d3708[m
Author: shuting <shuting@nirmata.com>
Date:   Fri Dec 1 20:59:52 2023 +0800

    feat: add new container flags (#1024)
    
    * add new container flags
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * Update content/en/docs/Installation/customization.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * split into two lines
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * split into two lines
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * reorder
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * Update content/en/docs/Installation/customization.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Installation/customization.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5548e29b94439c22df1b8eac14b58232b5670c62[m
Merge: 104af8fd f8d72fc3
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Fri Dec 1 18:15:07 2023 +0530

    Merge branch 'main' into cosign-new-docs

[33mcommit 104af8fddc67b494270a8b71689d466630f6e2cb[m
Merge: 1cea18bf f1b6c47a
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Fri Dec 1 18:14:46 2023 +0530

    Merge branch 'main' into cosign-new-docs
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit f8d72fc3d634be4e9c5d1961bce5602f3cc68e29[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Dec 1 04:43:17 2023 -0800

    update architecture diagram (#978)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f1b6c47af224339ebf7e731db86e1f6e686f0696[m
Author: shuting <shuting@nirmata.com>
Date:   Fri Dec 1 20:29:39 2023 +0800

    Add release-1.11 blog (#1014)
    
    * add release-1.11 blog
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * fix yaml
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * fix indentation
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * fix indentation
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * Update content/en/blog/releases/1-11-0/index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    
    * fix test YAML name
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Signed-off-by: shuting <shuting@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f7d612a60e96c7b7f7077496ef0c8ee133a81e80[m
Author: Mariam Fahmy <mariam.fahmy@nirmata.com>
Date:   Fri Dec 1 14:26:32 2023 +0200

    add docs for applying VAPs using CLI (#1015)
    
    * add docs for applying VAPs using CLI
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * fix
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * fix
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    ---------
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bd7a2af9e92d3293ff98c3e9ef7429d9a075976f[m
Author: Zadkiel Aharonian <zadkiel.aharonian@gmail.com>
Date:   Fri Dec 1 13:22:34 2023 +0100

    docs: update Grafana Dashboard page (#1019)
    
    * docs: update Grafana Dashboard page
    
    Signed-off-by: Zadkiel Aharonian <hello@zadkiel.fr>
    
    * Update content/en/docs/Monitoring/bonus-grafana-dashboard.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Zadkiel Aharonian <hello@zadkiel.fr>
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 504520b79f8b10ad82d4a8aa8995a7638c4551e4[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Fri Dec 1 17:48:36 2023 +0530

    feat: add image verify cache docs (#1026)
    
    * feat: add image verify cache docs
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    
    * Update content/en/docs/Writing policies/verify-images/_index.md
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2c0a6492b37f0890c64c1fe06680a8eb26c67da9[m
Author: Mariam Fahmy <mariam.fahmy@nirmata.com>
Date:   Fri Dec 1 14:14:26 2023 +0200

    use the new schema for values, userInfo and test in apply/test commands (#1025)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>

[33mcommit 1cea18bfd2b1006dc87c4c02d0f388d7c0f711f2[m
Merge: 7857baea 572132fc
Author: shuting <shuting@nirmata.com>
Date:   Fri Dec 1 15:02:42 2023 +0800

    Merge branch 'main' into cosign-new-docs

[33mcommit 572132fc51f72ab7d7f875319824a692e77c370a[m
Author: AdamKorcz <44787359+AdamKorcz@users.noreply.github.com>
Date:   Thu Nov 30 10:02:11 2023 +0000

    Add  2023 Kyverno security audit report (#1022)
    
    * Add 2023 Kyverno security audit report
    
    Signed-off-by: AdamKorcz <44787359+AdamKorcz@users.noreply.github.com>
    Signed-off-by: Adam Korczynski <adam@adalogics.com>
    
    * Update content/en/blog/general/2023-security-audit/index.md
    
    Co-authored-by: Marcel <marcel@giantswarm.io>
    Signed-off-by: AdamKorcz <44787359+AdamKorcz@users.noreply.github.com>
    
    ---------
    
    Signed-off-by: AdamKorcz <44787359+AdamKorcz@users.noreply.github.com>
    Signed-off-by: Adam Korczynski <adam@adalogics.com>
    Co-authored-by: Marcel <marcel@giantswarm.io>

[33mcommit afcc1d21070266f0119164c6ef3e6dae4c9c4030[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Nov 28 10:59:49 2023 -0500

    Updates for 1.11 (#1017)
    
    * add round() filter
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add new spec fields
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add note about SSA
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add matchConditions
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add wildcard support for matching subjects
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * Update content/en/docs/Installation/customization.md
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 7857baea69ba2dc5cac20aaf6c3cd7d667c1b72b[m
Merge: 5c16adb6 9a20af28
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Nov 24 09:29:27 2023 -0800

    Merge branch 'main' into cosign-new-docs

[33mcommit 5c16adb6e47ce194f77aee292ca985baa9e90790[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Wed Nov 22 20:02:06 2023 +0530

    feat: typos
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 2ba4f640fa52effb22ff1b8c4fd5dc881e6ccf52[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Wed Nov 22 20:00:37 2023 +0530

    feat: reviewed changes
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 9a20af28c3b1fb22959d263646af16017bbbd9d2[m
Author: Andreas Brehmer <38314220+anbrsap@users.noreply.github.com>
Date:   Mon Nov 20 14:19:18 2023 +0100

    Add doc for JMESPath function `lookup` (#841)
    
    Signed-off-by: Andreas Brehmer <andreas.brehmer@sap.com>

[33mcommit de1b770ddc131331a1cebbb084d8702ade54b877[m
Author: Chandan-DK <chandandk468@gmail.com>
Date:   Sat Nov 18 23:05:37 2023 +0530

    enhancement: reference kyverno cli github action (#975)
    
    * enhancement: reference kyverno cli github action
    
    Signed-off-by: Chandan-DK <chandandk468@gmail.com>
    
    * edit workflow yaml
    
    Signed-off-by: Chandan-DK <chandandk468@gmail.com>
    
    * modify
    
    Signed-off-by: Chandan-DK <chandandk468@gmail.com>
    
    * add images
    
    Signed-off-by: Chandan-DK <chandandk468@gmail.com>
    
    * edit yaml
    
    Signed-off-by: Chandan-DK <chandandk468@gmail.com>
    
    * edit text
    
    Signed-off-by: Chandan-DK <chandandk468@gmail.com>
    
    * use folder path for images instead of image URLs
    
    Signed-off-by: Chandan-DK <chandandk468@gmail.com>
    
    * update release version
    
    Signed-off-by: Chandan-DK <chandandk468@gmail.com>
    
    ---------
    
    Signed-off-by: Chandan-DK <chandandk468@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit e1ee434e0a58f8d93483db1b8bb3966cf0513528[m
Merge: 97f43f49 353c52a1
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Nov 18 09:12:42 2023 -0500

    Merge branch 'main' into cosign-new-docs

[33mcommit 353c52a1cce5fbf8e8d4c6525c726475fe6f2810[m
Author: Mariam Fahmy <mariam.fahmy@nirmata.com>
Date:   Sat Nov 18 15:28:08 2023 +0200

    use v2beta1 of exceptions and cleanup policies (#1006)
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ae72e03c1a9a698ff5ec1dcda50c50aad1ecdfac[m
Author: Stephen Lang <skl@users.noreply.github.com>
Date:   Sat Nov 18 12:42:11 2023 +0000

    fix: Update Grafana Dashboard JSON URL (#1016)
    
    Signed-off-by: Stephen Lang <stephen.lang@grafana.com>

[33mcommit 30fb1010a3412cf98b4e145fe329dd34e6866fd7[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 8 11:26:25 2023 -0500

    Render policies (#1003)
    
    render
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 1c4f8b3e992e452e956b28c2ad36764c770d31d2[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 8 08:13:03 2023 -0500

    Render policies (#1001)
    
    render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bc05bcbe24c1502a9488155b937868b7b1e38beb[m
Author: shuting <shuting@nirmata.com>
Date:   Wed Nov 8 21:04:11 2023 +0800

    Update maintainers off-boarding process (#1000)
    
    update maintainer off-boarding process
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit a839faf8ea890b6ab7384a6f13e81527a1cb6e5a[m
Author: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
Date:   Mon Nov 6 18:26:15 2023 +0530

    feat: add documentation for imageRegistryCredentials (#991)
    
    * feat: add documentation for imageRegistryCredentials
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    * Update content/en/docs/Writing policies/verify-images/_index.md
    
    Signed-off-by: shuting <shutting06@gmail.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    Signed-off-by: shuting <shutting06@gmail.com>
    Co-authored-by: shuting <shutting06@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 97f43f49139be20294de43d95f62a7443501fdaf[m
Merge: bfcbf222 c72fdb16
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Nov 6 07:55:06 2023 -0500

    Merge branch 'main' into cosign-new-docs

[33mcommit c72fdb1634d6b8f5fe495870f0c635a641dac863[m
Author: shuting <shuting@nirmata.com>
Date:   Mon Nov 6 20:54:13 2023 +0800

    Update the Community page (#996)
    
    * add maintainers meeting
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * remove links
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * clarify meetings
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * forma
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * Update content/en/Community/_index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shutting06@gmail.com>
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * Update content/en/Community/_index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shutting06@gmail.com>
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    * Update content/en/Community/_index.md
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>
    Signed-off-by: shuting <shutting06@gmail.com>
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    
    ---------
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>
    Signed-off-by: shuting <shutting06@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 8d921974fef2b46dff2d39a729471b1bb594e25f[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 1 09:09:59 2023 -0400

    remove duplicate hugo (#999)
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bb67929162e2555debc2b8bbbe09d241998333e9[m
Author: Mike Bryant <mike@mikebryant.me.uk>
Date:   Wed Nov 1 12:48:14 2023 +0000

    fix: Use correct function name (#998)
    
    Signed-off-by: Mike Bryant <mike.bryant@mettle.co.uk>

[33mcommit 3ecae9635f73253ff69b9287ea5e87d3b4fd94d1[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 1 03:41:55 2023 -0400

    Fix Devcontainer to use Hugo Extended (#997)
    
    use extended
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit 7bad8602c209bfa5382dfcc711ad1b7bbd378bbd[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Oct 30 15:45:06 2023 -0400

    Devcontainers (#994)
    
    * add devcontainer
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * rewrite contributing guide
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bfcbf2228589cd39edde8e44428983489a5af420[m
Merge: 182821da d05766b3
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Mon Oct 30 16:18:48 2023 +0530

    Merge branch 'main' into cosign-new-docs
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit 182821da529f6d2866e65b62bcebea193b6870e6[m
Author: Vishal Choudhary <vishal.choudhary@nirmata.com>
Date:   Mon Oct 30 16:18:27 2023 +0530

    fix: update with new changes
    
    Signed-off-by: Vishal Choudhary <vishal.choudhary@nirmata.com>

[33mcommit d05766b313fcafc1211f96d3bfa1b6b2af70ac45[m
Author: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
Date:   Thu Oct 26 19:21:41 2023 +0530

    feat: Add manifests for attestation verification using notary (#990)
    
    * feat: add manifests
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    * feat: add image info
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    * fix: add review changes from Chip
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>

[33mcommit 53cdf55f32044dc155462dff02064f4df410836d[m
Author: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
Date:   Thu Oct 19 15:53:10 2023 +0530

    feat: add docs for cosign 2.0 enhancements
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>

[33mcommit 5dad3259f4308e0c6f51e4ea1b4fb8485a5deab7[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Oct 17 11:20:31 2023 -0400

    1.11 updates (part 1) (#979)
    
    * VAP blog minor cleanup
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * remove incorrect sentence re patch ops
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * remove inaccurate AWS statement
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add wildcard match format to list
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * better mutate page description
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * add note about protected fields during mutation
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * cleanup docs for 1.11
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * verifyImages tweaks; add blog link
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    * extend note on Helm escaping
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 4ee00e50176703f3f371c970c9d5d58ee4b701de[m
Author: Rodrigo Fior Kuntzer <rodrigofkuntzer@gmail.com>
Date:   Fri Oct 13 09:59:43 2023 +0200

    fix: allow dropping metrics, labels and configuring histogram bucket boundaries to avoid high cardinality (#974)
    
    Signed-off-by: Rodrigo Fior Kuntzer <rodrigo@miro.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit da9d0b0c9f2538e874d8642b3efc2cc8ede879df[m
Author: Patrik Jonsson <patrik.jonsson@gmail.com>
Date:   Mon Oct 9 13:51:07 2023 +0200

    Move dot in Kyverno Policies documentation page (#980)
    
    Signed-off-by: Patrik Jonsson <patrik.jonsson@gmail.com>

[33mcommit 0a53f5a9fcb74b19512424298a0fd8d87dd625e2[m
Author: Mariam Fahmy <mariamfahmy66@gmail.com>
Date:   Sun Oct 8 14:43:24 2023 +0300

    Add a new blog about applying VAPs to resources using Kyverno CLI (#957)
    
    * Add a new blog about applying VAPs to resources using Kyverno CLI
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    * fix: modify the blog
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    
    ---------
    
    Signed-off-by: Mariam Fahmy <mariam.fahmy@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit df22efbd6aa7f1e82bddeeebe6b85723d0759ba0[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 4 10:41:57 2023 -0700

    update form URL (#976)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 513b03be7b309615bdfc2bb8fe80e21534b2125d[m
Author: Satyajit Behera <105061492+satyazzz123@users.noreply.github.com>
Date:   Sun Oct 1 19:16:51 2023 +0530

    fixed the typo in JMSEPath in issue#972  (#973)
    
    * fixed the typo in JMSEPath in issue#972
    
    Signed-off-by: satyazzz123 <beherasatyajit716@gmail.com>
    
    * added the omitted code formatting around the namespace
    
    Signed-off-by: satyazzz123 <beherasatyajit716@gmail.com>
    
    ---------
    
    Signed-off-by: satyazzz123 <beherasatyajit716@gmail.com>

[33mcommit b61266b1136a248b4f54558f58869c8cc6968a01[m
Author: alexandrututunaru <64774870+alexandrututunaru@users.noreply.github.com>
Date:   Sat Sep 30 13:27:42 2023 +0200

    Add solution in the EKS troubleshooting section (#959)
    
    Signed-off-by: Alexandru Tutunaru <alexandru.tutunaru@kbc.be>
    Co-authored-by: Alexandru Tutunaru <alexandru.tutunaru@kbc.be>

[33mcommit 41d883c60b68ff7eef02ac55040717f9bdfd6c30[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Sep 22 14:19:27 2023 +0200

    fix: webhookTimeout flag description not clear enough (#970)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 8051b1af6104389aecd3aafb3c9bc239f705ae87[m
Author: Chandan-DK <chandandk468@gmail.com>
Date:   Sun Sep 17 19:29:28 2023 +0530

    fix: env should be equal to qa (#967)
    
    Signed-off-by: Chandan-DK <chandandk468@gmail.com>

[33mcommit 991d9c4657a176d7ad932c2916ea07ec28c9af32[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Sep 12 08:45:19 2023 -0700

    fix typo (#962)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit fbb41bbd2c9627feb1216c35e9068eefa23f68b7[m
Author: AdamKorcz <44787359+AdamKorcz@users.noreply.github.com>
Date:   Tue Sep 12 14:38:16 2023 +0100

    Add blogpost and report for Kyvernos fuzzing audit (#960)
    
    * Add blogpost and report for Kyvernos fuzzing audit
    
    Signed-off-by: AdamKorcz <adam@adalogics.com>
    
    * nits
    
    Signed-off-by: AdamKorcz <adam@adalogics.com>
    
    ---------
    
    Signed-off-by: AdamKorcz <adam@adalogics.com>

[33mcommit f59c57c3becfb588a2bebe48a9af21811416aac1[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Aug 29 08:16:49 2023 -0400

    render changes (#953)
    
    Signed-off-by: chipzoller <chipzoller@gmail.com>

[33mcommit c5656e81e60d6903b2dd67901a5554e5c54ac533[m
Author: syedsadath-17 <90619459+sadath-12@users.noreply.github.com>
Date:   Tue Aug 29 15:51:09 2023 +0530

    Typo Correction in Introduction Page (#954)
    
    Corrected Typo
    
    Signed-off-by: sadath-12 <sadathsadu2002@gmail.com>

[33mcommit 0261d32c02e556699f549bb188cba06dc19cd4a2[m
Author: Ved Ratan <82467006+VedRatan@users.noreply.github.com>
Date:   Mon Aug 21 00:45:20 2023 +0530

    Fix: [Render] Support for CleanupPolicies (#871)
    
    * added docuentations for sum filter
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    
    * added sample policy
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    
    * applied the changes
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    
    * added cleanup support
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    
    * fix
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    
    * enhancement for CRs
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    
    ---------
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    Co-authored-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit c0da1fc5087e358453807a32455eec153cbf3814[m
Author: Swastik Patel <swastikpatel29@gmail.com>
Date:   Sun Aug 20 21:35:51 2023 +0530

    fixing navbar on zooming in (#943)
    
    Signed-off-by: swastik <swastikpatel29@gmail.com>
    Co-authored-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 0999ff07889ca4d2a7ee6bc1ae4a0b5664f59976[m
Merge: 6a9f132f 0559ab0d
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Aug 18 18:26:41 2023 +0200

    Update background.md (#949)

[33mcommit 0559ab0dac213c928775461e1866e44074b7f510[m
Merge: 1bef3a65 6a9f132f
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Aug 18 18:01:45 2023 +0200

    Merge branch 'main' into typo-fixed

[33mcommit 1bef3a65db97d0aa2093acefd760b7c431a78289[m
Author: Swastik Patel <swastikpatel29@gmail.com>
Date:   Fri Aug 18 20:22:32 2023 +0530

    Update background.md
    
    Signed-off-by: Swastik Patel <swastikpatel29@gmail.com>

[33mcommit 6a9f132fed13c99c26798ad1a2f5e3c71320d848[m
Author: shuting <shuting@nirmata.com>
Date:   Fri Aug 18 16:12:19 2023 +0800

    Add a new blog "Verifying images in a private Amazon ECR with Kyverno and IAM Roles for Service Accounts (IRSA)" (#944)
    
    add new blog
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 5051c1ead46fdc27e9ac569dbfb66ae9802069e9[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Aug 9 01:41:52 2023 -0400

    Updates for 1.10.2 (#936)
    
    * add the 2 new flags (--aggregateReports and --policyReports) for 1.10.2
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * minor fixes
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify background scans in PEs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 7eab19ae008df2d680b6b05c6812ba8e63f76b4a[m
Author: Pradyot Ranjan <99216956+prady0t@users.noreply.github.com>
Date:   Thu Aug 3 03:16:08 2023 +0530

    Update mutate.md, changed `operation` to `operations` (#935)
    
    Update mutate.md
    
    Signed-off-by: Pradyot Ranjan <99216956+prady0t@users.noreply.github.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bcf6ca75bd60650215e95fe79f6a69f36fa88e2f[m
Author: Weru <fromweru@gmail.com>
Date:   Thu Aug 3 00:42:01 2023 +0300

    Patch regression after #893 (#904)
    
    * Upgrade to docsy 0.7.0
    Signed-off-by: Andreas Deininger <andreas@deininger.net>
    
    * use docsy's dedicated styles' override files
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * justify menu links right
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * parse lead shortcode as md
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * add smooth scroll & restrict overscroll
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * combine custom css files
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * bump min Hugo v0.75.0 > v0.109.0
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * pre-install postcss
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * fix logo aspect ratio
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * restore mobile nav collapse function
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * fix footer overflow
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * use hugo v0.114.0 on netlify
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * restore button styling
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * update go & node versions
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * update go-node versions all environments
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * update to docsy 0.7.1
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * exclude mermaid syntax snippets
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * restore snippets styling
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * update code snippets color
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    ---------
    
    Signed-off-by: weru <fromweru@gmail.com>
    Co-authored-by: Andreas Deininger <andreas@deininger.net>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5d7f154cf68cb5e044b4d71c2c8a229901a1407a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jul 29 17:44:16 2023 -0400

    New blog on OpenShift MachineSet (#931)
    
    * add blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * finalize
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 99cfd7a50d54c0f83508c9af1f92cc0482432c24[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jul 28 11:08:35 2023 -0400

    render all policies (#928)
    
    * render all policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * wipe and render again
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2eb55537a827364d5477c5c9679fea3867b4e91b[m
Author: Devaansh Bhandari <107868772+brf153@users.noreply.github.com>
Date:   Wed Jul 19 16:26:24 2023 +0530

    changed the readme.md and contributing.md file (#922)
    
    * changed the readme.md and contributing.md file and removed recurse-submodule option
    
    Signed-off-by: brf153 <153hsb@gmail.com>
    
    * done with readme.md and contributing.md file
    
    Signed-off-by: brf153 <153hsb@gmail.com>
    
    ---------
    
    Signed-off-by: brf153 <153hsb@gmail.com>

[33mcommit 6a05ade3af3b3d773c8191583110594d6d45c518[m
Merge: aae46581 0809a4f1
Author: Chip Zoller <chip@nirmata.com>
Date:   Mon Jul 17 06:10:40 2023 -0400

    add enableDeferredLoading flag (#913)

[33mcommit 0809a4f19a7183694369faced41fae7beeeac6bb[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jul 17 05:45:05 2023 -0400

    expand mutate existing
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 52759d1c17cad0d0a117c9f09036ef6ba6eea7a2[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jul 17 05:15:14 2023 -0400

    change community meeting to NOK
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 47170c748d6cfb6962871f36696e0778a9958638[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 12 17:59:12 2023 +0530

    fix link
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 09dd9d716bf3a7e6dc67a86507f9bdb516b2a007[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Jul 11 14:30:01 2023 +0530

    add enableDeferredLoading flag
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit aae46581c34f0b22b2605fe80e0045d5bdb89bad[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jul 8 22:20:41 2023 -0400

    Render policies (#910)
    
    render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 043e301e5a1f6428415e8e79a516f70877e5d84e[m
Author: Emmanuel Ferdman <emmanuelferdman@gmail.com>
Date:   Tue Jun 20 14:47:10 2023 +0300

    fix: update links in "Gatekeeper Migration Guide" page (#907)
    
    Signed-off-by: emmanuel-ferdman <35470921+emmanuel-ferdman@users.noreply.github.com>

[33mcommit 843c8ad765d2ec418d4d1ea45e449cfde246f36e[m
Author: SANCHITA MISHRA <96846744+sanchita-07@users.noreply.github.com>
Date:   Sat Jun 17 08:13:14 2023 +0530

    fix: update the path of kyverno-cli binary (#905)
    
    Signed-off-by: sanchita-07 <sanchita.mishra1718@gmail.com>

[33mcommit d97ed1885ba1be360a8ea1d81f7d2e56f28363b6[m
Merge: 0dde157a 063a559f
Author: Chip Zoller <chip@nirmata.com>
Date:   Tue Jun 13 08:45:47 2023 -0400

    fix flag description (#899)

[33mcommit 063a559f306fe18b4f4021a01044cad4c0d7e684[m
Merge: 6b246020 0dde157a
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Jun 13 08:45:31 2023 -0400

    Merge branch 'main' into flagfix

[33mcommit 0dde157a98fcbff53db2855fb312d0a3ec497da6[m
Author: Emmanuel Ferdman <emmanuelferdman@gmail.com>
Date:   Tue Jun 13 14:21:19 2023 +0300

    fix: update broken link to "Disallow Default Namespace" page (#902)
    
    Signed-off-by: emmanuel-ferdman <35470921+emmanuel-ferdman@users.noreply.github.com>

[33mcommit 6b24602048702504083264c5aac3ad41058e4914[m
Merge: eb4ae2ae ed4c9367
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jun 12 20:01:45 2023 -0400

    Merge branch 'main' into flagfix

[33mcommit ed4c93678bba86ab904c0d49a50f2d172733674c[m
Merge: 57626f14 0135d5ce
Author: Chip Zoller <chip@nirmata.com>
Date:   Mon Jun 12 19:59:08 2023 -0400

    PSA blog updates (#900)

[33mcommit 0135d5cefcbbce28357cfdf443b9ff9c672dc0cf[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jun 12 19:57:03 2023 -0400

    updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit eb4ae2ae5dfd39d6e60ef06d0450b89e2a823cec[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jun 12 12:20:50 2023 -0400

    fix flag description
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 57626f14b22b0363c3b96b6dc60b950c17828aab[m
Merge: cdec189c 682d40c6
Author: Chip Zoller <chip@nirmata.com>
Date:   Mon Jun 12 04:47:43 2023 -0400

    Docfixes (#898)

[33mcommit cdec189cc22f2ea4949eac79adf5af46c7297d74[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jun 12 02:28:17 2023 -0400

    New PSA blog (#895)
    
    * save
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * newline
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 682d40c6e7f2328933c61938ad86c09ab5285c6d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Jun 11 10:19:36 2023 -0400

    improved description of skipResourceFilters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit af913d2cb3b29b4adc992889eee9d4389df45d49[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Jun 11 10:16:45 2023 -0400

    clarify description of exceptionNamespace
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 512a95434661d9a30e88b2dd6628940a0e3ce5f7[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Jun 11 10:15:07 2023 -0400

    fix link
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 66407f0b4fd0add15a04933d3302fc88dc6e490c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Jun 11 10:13:12 2023 -0400

    add missing auto-gen note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit e3b1d8b8840811484d3c7dedf499801147ea7e8d[m
Author: Emmanuel Ferdman <35470921+emmanuel-ferdman@users.noreply.github.com>
Date:   Sun Jun 11 13:51:04 2023 +0300

    fix: update broken link to background scans page (#897)
    
    * fix: update broken link to background scans page
    
    Signed-off-by: emmanuel-ferdman <35470921+emmanuel-ferdman@users.noreply.github.com>
    
    * fix: update broken link to background scans page
    
    Signed-off-by: emmanuel-ferdman <emmanuelferdman@gmail.com>
    Signed-off-by: emmanuel-ferdman <35470921+emmanuel-ferdman@users.noreply.github.com>
    
    * fix: update broken link to background scans page
    
    Signed-off-by: emmanuel-ferdman <emmanuelferdman@gmail.com>
    Signed-off-by: emmanuel-ferdman <35470921+emmanuel-ferdman@users.noreply.github.com>
    
    ---------
    
    Signed-off-by: emmanuel-ferdman <35470921+emmanuel-ferdman@users.noreply.github.com>
    Signed-off-by: emmanuel-ferdman <emmanuelferdman@gmail.com>

[33mcommit 5b3d9b00911ee5def16f9b60d031e905b99f1398[m
Author: Frank Jogeleit <frank.jogeleit@web.de>
Date:   Mon Jun 5 15:04:00 2023 +0200

    blog: Let's Play Kyverno (#890)
    
    Signed-off-by: Frank Jogeleit <frank.jogeleit@lovoo.com>

[33mcommit 70c2a839e2f37e53bc5b4893e1ac4fd5f49648ef[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jun 3 08:06:28 2023 -0400

    Use "Notary" (#888)
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 37f6c83f2dbeeebb67d1f6f9a0d4889cd7625267[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue May 30 14:27:48 2023 -0700

    collapse roles and add self-service note for Contributors (#883)
    
    * collapse roles and add self-service note for Contributors
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * fix typos
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * flip columns and revert contributor responsibilities
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit ef93ca656a7369f152a09f9c1839f1bd6b494909[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue May 30 11:38:59 2023 -0400

    Update release menu (#878)
    
    * fix operator
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add scale test results
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * swap rows
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update versions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 8ff14e5ce9984de326e49333148ce8c6924096ed[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue May 30 11:31:56 2023 -0400

    Add scale testing results (#877)
    
    * fix operator
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add scale test results
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * swap rows
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit c0fa2482983447b1a63f51965734ed687aa198a6[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue May 30 04:32:52 2023 -0700

    Notary and other minor changes (#876)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit c299451203817d90348c6d0082531a74857b1e5c[m
Merge: bda0226c 539ff0af
Author: Chip Zoller <chip@nirmata.com>
Date:   Tue May 30 07:26:28 2023 -0400

    expand and improve mutation docs for conditionals and foreach (#867)

[33mcommit 539ff0af4710a5b863913502820f582ed65b1a0d[m
Merge: fd04ac83 bda0226c
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue May 30 07:14:41 2023 -0400

    Merge branch 'main' into mutate-improvements

[33mcommit bda0226c5bfe4d3fa0f0a60d2c263c33197449f6[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue May 30 07:13:56 2023 -0400

    Fix link (#874)
    
    * add psp migration blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fixes
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * comments
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarifications about exclusions; misses
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add step zero using CLI
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix link
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * psp migration reference
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit a51e26b721a8a006a2a7d6930f30f4bd8b855cd3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue May 30 07:06:08 2023 -0400

    Kyverno 1.10 blog (#870)
    
    * add blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * address comments
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update date
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit fd04ac83c6388fa424aafecb3909e116ac135706[m
Merge: 06a66ff8 0ff3d141
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon May 29 07:12:52 2023 -0400

    Merge branch 'main' into mutate-improvements

[33mcommit 0ff3d141174ed8e11277264a57e5731bf2e10415[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 29 13:08:47 2023 +0200

    docs: add certificate renewal infos (#873)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit afdc3e2314d1c9fdbb77c8a6309c299ed119b220[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun May 28 19:25:33 2023 -0400

    Add PSP migration blog (#864)
    
    * add psp migration blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fixes
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * comments
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarifications about exclusions; misses
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add step zero using CLI
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 06a66ff84541ec68d2310a5fb2216823f2354851[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat May 27 09:37:47 2023 -0400

    expand and improve mutation docs for conditionals and foreach
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4ac99b8c9de76f7139910647c7a5bc4e62984eb8[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed May 24 15:19:00 2023 +0200

    add troubleshooting reports section (#861)
    
    * add troubleshooting reports section
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fixes
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    ---------
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5cb02c44beae2da12b909c06243201e9815dffe2[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed May 24 09:17:53 2023 -0400

    More 1.10 docs (#852)
    
    * rework deny docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * rewrite preconditions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add message to verifyImages section
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * notes to variables
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add Playground menu shortcut
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * foreach notes
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update mutate existing
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix misspelling
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * generate updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * security updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh and extend troubleshooting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * tweak description
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * polish autogen
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * polish cleanup
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * polish jmespath
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add more operations in match-exclude
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * minor tweak to mutate
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * new tip
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 10a39fb465cb55c2d43dcf25e845bbb5bb39f7f5[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 22 17:22:19 2023 +0200

    update tracing docs (#860)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 444bb7da17d9e3b9e5ade59837261aaeb37d23f6[m
Merge: ea09ee20 ab9e7fcd
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 22 16:28:35 2023 +0200

    fix: certificates docs (#853)

[33mcommit ab9e7fcdbb5d1d75e4e0361d38547704c2403d92[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 22 16:24:59 2023 +0200

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 8dbb009ce32ea66f39b8696f64cabb3e287c3cdf[m
Merge: 3a07f214 ea09ee20
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue May 16 21:46:13 2023 +0200

    Merge branch 'main' into revisit-certs-docs

[33mcommit ea09ee20383ea776b644d0da798afa62ab534d50[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue May 16 21:40:58 2023 +0200

    fix: metrics docs (#851)
    
    * fix: metrics docs
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * index
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    ---------
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 3a07f21436e1eef7ab51b3a15e11c86c8903ea6d[m
Merge: 97d67bd8 1efd142c
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue May 16 21:07:20 2023 +0200

    Merge branch 'main' into revisit-certs-docs

[33mcommit 97d67bd8c60ac54f528da7dc05c993624650c603[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue May 16 16:18:42 2023 +0200

    fix: certificates docs
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 1efd142ce208ebef752435b68caad77634b52b76[m
Merge: c497b2bb d73719bd
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 15 19:05:31 2023 +0200

    fix: policy results info metric (#850)

[33mcommit d73719bd85cdae2206edfbcda3732a0793e4e2e3[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 15 18:48:38 2023 +0200

    fix: policy results info metric
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit c497b2bba3b9caf8e225e5b61bc3a1604cbe47d8[m
Merge: cd748f32 6b3e05d3
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 15 18:42:54 2023 +0200

    fix: policy rule info total (#849)

[33mcommit 6b3e05d37e77731082fc3815d81c240fefc440e7[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 15 18:29:38 2023 +0200

    fix: policy rule info total
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit cd748f326e310ae2988ecd04364aa0ed496cd409[m
Merge: 94823294 658da8b6
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 15 18:21:50 2023 +0200

    fix: policy rule info total metric values (#848)

[33mcommit 658da8b6453d5a1c87fccdc82af5e5bb121be0d4[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 15 18:14:43 2023 +0200

    Update content/en/docs/Monitoring/policy-rule-info-total.md
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit e52e227c9337f59b9d76341b02442fc7301aae6a[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 15 18:08:46 2023 +0200

    fix: policy rule info total metric values
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 94823294d42386f12c7fc1426f1dfb1de30aa47f[m
Merge: c7edb411 d49af4d1
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 15 18:06:03 2023 +0200

    fix: metrics nits (#847)

[33mcommit d49af4d1cff9db1c520285d25247d7400f242b51[m
Merge: 606509ef c7edb411
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 15 17:58:25 2023 +0200

    Merge branch 'main' into nit-metrics

[33mcommit 606509efaf3172d70b5fc637a03b22ecabc51463[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 15 17:57:41 2023 +0200

    fix: metrics nits
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit c7edb41136d6f6021aa32360739585c6c04ba2c3[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Mon May 15 17:55:42 2023 +0200

    feat: add http requests metrics doc (#846)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit bf2878ccd083e06ed8ff062a6ef107a9f28281b9[m
Merge: b9113737 b1a1043d
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon May 15 11:29:01 2023 -0400

    add notes on add anchor (#845)

[33mcommit b1a1043df645dcaa6c4a5159972100ef31c25d73[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon May 15 11:24:20 2023 -0400

    add notes on add anchor
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b91137378760ec9bf2d7b16c722d2c287f93af3c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun May 14 17:48:58 2023 -0400

    Add Service call and versioning (#843)
    
    * update policy settings
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add service calls
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update sample
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update versioning strategy
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * more clarification of `--backgroundScanWorkers`
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add trim_prefix()
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add jmesPath to verifyImages imageExtractors
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * to_boolean
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update items() filter with support for arrays
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update x509_decode() to mention CSR support
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add image_normalize()
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add sum()
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix, remove duplicate sum()
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add gitops notes for mutate
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * move and rework background scan page
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * reswizzle Writing Policies sections, names, and descriptions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * additions to policy exceptions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * extend reporting docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add operations, fix samples
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * note on report chunking
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update all JSON patch examples to use YAML and not JSON
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add extra note on --autoUpdateWebhooks
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 9bf720db2c22ff12cda58a7658ac7a82eca41bad[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri May 12 08:47:53 2023 -0400

    Fixes (#842)
    
    * change Artifact Hub link to home page
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * tighten up quick starts
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix links
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update policy structure graphic
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 31c2b4f02e1f0abf88e440a560c2d138d03d8636[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri May 12 06:29:24 2023 -0400

    1.10 updates (#833)
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note with link to annotation guide
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update Resource Filters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Introduction updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * replace kyverno-installation graphic
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add AKS note, update Helm section
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * rewrite HA section
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * flag tweaks
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix subresource references
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update some cert info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix trademark disclaimer
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * tweaks, add Notes for EKS Users section
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update CLI docs for jp command
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh Roles and Permissions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update ConfigMap keys
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh container flags
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * backgroundScan flag clarification
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh Webhooks section
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update Resource Filters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * adjust Namespace Selectors
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * temp adjustment of Resource Requests and Limits
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * tweak Proxy
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * finish Upgrade and Uninstallation docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * move controller internals to developer docs; clarify point
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Scaling section
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * tweak
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Save, replace graphic
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update graphics
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add --omit-events flag
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * finish quick starts
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * restructure installation page with sub-pages
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 45b234f7a9b3980c9145edf590332e7b3a343d4a[m
Author: Ved Ratan <82467006+VedRatan@users.noreply.github.com>
Date:   Wed May 10 17:04:48 2023 +0530

    [Render] Disregard files used for kuttl tests (#835)
    
    fixed 822
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>

[33mcommit c98cd728adfda8ea61f72aff8587063aa62f6cd7[m
Author: Jaideep Solania <jaideep2912@gmail.com>
Date:   Mon May 8 01:53:47 2023 +0530

    Resources Page Hyperlinks Fixed (#837)
    
    Signed-off-by: Jaideep Solania <jaideep2912@gmail.com>

[33mcommit 10b96da5445845e18cdada5bc0ae2dd4470c58e3[m
Author: Anusha Hegde <anusha.hegde@nirmata.com>
Date:   Fri May 5 18:23:02 2023 +0530

    Add Enterprise Kyverno release compatibility info (#820)
    
    Signed-off-by: Anusha Hegde <anusha.hegde@nirmata.com>

[33mcommit 66810ab227113e7194e3ef7c86c6fd3e670a360e[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu May 4 08:24:37 2023 -0400

    render policies (#831)
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 156e2f2160afe9a900eba78e90e72f5f5d635666[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 24 10:03:44 2023 -0400

    update note for OpenShift (#826)
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 9b6bdaf2a5f783b445d0d18ad7edf6ad3ac91773[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Apr 20 23:35:10 2023 -0400

    Render policies (#823)
    
    * new version
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix flags
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add profileAddress flag
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add heading for video playlists
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add details on Nirmata for Kyverno Open Source
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add Kyverno use cases playlist
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    Co-authored-by: shuting <shuting@nirmata.com>

[33mcommit 5f1c1d22ba44f916e46db5d35e975b3c1d84eac1[m
Author: Dennis Hemeier <d.hemeier@cloudpirates.io>
Date:   Tue Apr 18 21:20:24 2023 +0200

    Add Troubleshooting section for high resource usage on AKS  (#789)
    
    * Add troubleshooting section for high resource usage on AKS
    
    Signed-off-by: Dennis Hemeier <d.hemeier@cloudpirates.io>
    
    * Change typo
    
    Signed-off-by: Dennis Hemeier <d.hemeier@cloudpirates.io>
    
    ---------
    
    Signed-off-by: Dennis Hemeier <d.hemeier@cloudpirates.io>

[33mcommit d00027eb24fb4d9f2742f893341dec661eceb1ae[m
Author: Ved Ratan <82467006+VedRatan@users.noreply.github.com>
Date:   Thu Apr 13 23:17:15 2023 +0530

    [Enhancement] Add docs for sum() JMESPath filter (#806)
    
    * added docuentations for sum filter
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    
    * added sample policy
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    
    * applied the changes
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    
    * applied the changes
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    
    * added cmd example
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>
    
    ---------
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>

[33mcommit bd55c2e78cfb4bcfd8d0903a4b079af69904897d[m
Author: Yurii Rochniak <yrochnyak@gmail.com>
Date:   Wed Apr 5 15:46:28 2023 +0200

    Docs: Exit with WARN code if no objects satisfy a policy (#799)
    
    Signed-off-by: Yurii Rochniak <yrochnyak@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 53c6557858939d74ae7caabd93981e116ffec422[m
Author: Vishal Choudhary <contactvishaltech@gmail.com>
Date:   Sat Apr 1 18:04:36 2023 +0530

    Blog about custom jmespath functions (#762)
    
    * added some custom filters
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    * added summary
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    * added all filters
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    * NIT
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    * added required changes
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    * requested changes
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    * revision
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    * revision
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    * NIT
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>
    
    ---------
    
    Signed-off-by: Vishal Choudhary <sendtovishalchoudhary@gmail.com>

[33mcommit 87ea6c14e23767dbe97b897e37d81769dbb27579[m
Author: Kanika Gola <kanikagola26@gmail.com>
Date:   Fri Mar 31 01:37:54 2023 +0530

    Homepage Hyperlinks Fixed (#803)
    
    Signed-off-by: Kanika <kanikagola26@gmail.com>

[33mcommit 427b8eaa8488c592709a5ffc6e3c32a20d4ba57a[m
Author: Zach Stone <z.stone91@gmail.com>
Date:   Thu Mar 23 20:05:58 2023 +0100

    Clarify default PolicyException namespace behavior (#797)
    
    Clarify default PolicyException namespace behavior.
    
    Signed-off-by: Zach Stone <zach@giantswarm.io>

[33mcommit 6781cebf171354ca4f4aee6da5571e9bc5356b22[m
Author: Maximilian Braun <maximilian.braun@sap.com>
Date:   Wed Mar 22 13:47:37 2023 +0100

    fix: typo in writing policies / variables (#794)
    
    Signed-off-by: Maximilian Braun <maximilian.braun@sap.com>

[33mcommit 317212fae22a3916a28572573450d5901bb9db92[m
Author: Ved Ratan <82467006+VedRatan@users.noreply.github.com>
Date:   Fri Mar 10 20:15:42 2023 +0530

    Add trademark disclosure  (#779)
    
    added trademark disclosure
    
    Signed-off-by: Ved Ratan <vedratan8@gmail.com>

[33mcommit 102d4177e64ba329471d7317663e66b75edba9a4[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Mar 3 02:50:55 2023 -0500

    Misc. doc updates (#776)
    
    * new version
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix flags
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add profileAddress flag
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add heading for video playlists
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add details on Nirmata for Kyverno Open Source
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add Kyverno use cases playlist
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bba928d040f809929b8275f80653890fc083bd31[m
Author: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>
Date:   Tue Feb 28 09:10:03 2023 -0500

    Bump golang.org/x/text from 0.3.4 to 0.3.8 in /render (#771)
    
    Bumps [golang.org/x/text](https://github.com/golang/text) from 0.3.4 to 0.3.8.
    - [Release notes](https://github.com/golang/text/releases)
    - [Commits](https://github.com/golang/text/compare/v0.3.4...v0.3.8)
    
    ---
    updated-dependencies:
    - dependency-name: golang.org/x/text
      dependency-type: direct:production
    ...
    
    Signed-off-by: dependabot[bot] <support@github.com>
    Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com>

[33mcommit 6534ef4407078e5dc0dd6bb744e9b6103f98bab4[m
Author: Yash Raj Singh <98258627+yrs147@users.noreply.github.com>
Date:   Tue Feb 7 18:42:58 2023 +0530

    Changed background definition (Fixes issue #757) (#761)
    
    * Changed background definition
    
    Signed-off-by: yrs147 <yashraj14700728@gmail.com>
    
    * Added Proposed Changes to background attribute
    
    Signed-off-by: yrs147 <yashraj14700728@gmail.com>
    
    ---------
    
    Signed-off-by: yrs147 <yashraj14700728@gmail.com>

[33mcommit 4e570e10dacd9656e066bf5d873219bd2d54951b[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Fri Feb 3 14:57:45 2023 +0100

    fix: remove --devel from tracing tutorials (#759)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit a39a7925266d7e27229d565ec66c0ac3def080e4[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Feb 1 23:12:07 2023 -0500

    new version (#756)
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit c040dfdff6733bd75de42e3fe08eaa8d26744ca3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Feb 1 12:54:01 2023 -0500

    1.9 updates - contributor guideline proposal (#754)
    
    * governance updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add details to non-falsifiable section
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * save
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix example
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * alpha warnings
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add PolicyException related flags
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add flags to note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * save
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * save
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clusterrole updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * colon
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * autogen note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix example; extend note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix and clarify
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * reference all YAML manifests from release artifacts
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add 1.9 CNCF livestream
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * enable blogs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    ---------
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit dec08aba520cae37a3dd7e733b6f9d003618f5fd[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jan 30 05:29:08 2023 -0800

    update GK migration and install (#750)
    
    * update GK migration and install
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * address comments
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6cb74ffec1cedf60200d2441b815a2f843e18419[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jan 30 05:26:55 2023 -0800

    update commercial support section (#751)
    
    * update commercial support section
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * add AWS + updates
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * remove OVH - no commercial support
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * fix spellings
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    ---------
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit aaefe2d5f12dfb035bd96f9e0661a78c90ebf39c[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Jan 17 20:34:32 2023 +0100

    feat: tracing docs (#744)
    
    * feat: tracing docs
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * walkthrough
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * tutorial
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * images
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fix helm
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * jaeger
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * fixes
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 702f6d2ce9b7ff164ebe71b4c6d3ec1c16540aab[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Jan 17 11:46:38 2023 -0500

    1.9 documentation updates (#733)
    
    * adjust
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add dumpPayload flag (copy of PR 696)
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * adjust IRSA to access AWS KMS
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * incorporate changes from PR 709
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * upgrade Docsy to 0.6.0
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix jmespath page formatting with Docsy fix picked up in 0.6.0
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add kyverno_client_queries_total metric docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add details on using K8s secret as publicKey
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update ClusterRole aggregation info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add extended subresource support
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix grammar
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add more subresources info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add subresources to CLI
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * CLI oci docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify resourceFilters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add mention of proxy support
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add troubleshooting for Kyverno throttling
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove filter labels from kyverno_policy_execution_duration_seconds metric
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add clarifying note on verifyImages
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add leaderElectionRetryPeriod flag
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove legacy note and section about generate existing
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * rewrite the generate docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove reference to multiple imagePullSecrets; add private reg trust
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add info on auto-gen ReplicaSets and ReplicationControllers
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note about resolving ArgoCD clashes
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add OpenShift 4.11 note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add 1.9 to compat. matrix; remove pre 1.6
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note clarifying auto-gen for metadata.namespace patterns
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add dry run to validate.manifests section
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note to mutate existing
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix precondition example; remove mention of deprecated operators
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add resource section with perf table
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove verifyImages from beta status
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note on predicate type inspection
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update attestation verification with new structure
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add/update troubleshooting for "policies not applied"
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add provenance verification steps
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add video link
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add info on ConfigMap caching
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add metric disabling with DataDog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * adjust all page weights to prepare for incoming pages
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * enable mermaid diagrams
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * initial write-up of PolicyExceptions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify performance table data
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add troubleshooting on policy authoring
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add tip on kubectl get kyverno
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add nested foreach in mutate
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * stance on fixing security vulns
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify note on resource table
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove backgroundScanInterval for now
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix space
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * initial cleanup docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove links to pre-1.6.0 docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * adjust weight
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add cve blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add draft 1.9 release blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove dupe post, remove new lines
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * blog updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix check-image policy
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * change references to validationFailureAction values to capital case
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * complete table mapping
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update link to Kyverno adopters form
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix variables in `images`
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add `image` var
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * verifyImages back to beta
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update Kyverno arch graphic
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * address comments from Vyom re. CLI subresources
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update cleanup vars
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * replace Kyverno-Policy-Structure.png
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * address comments: clarify blog sample
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * blog updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * move table
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * readme note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * change page type
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh kyverno-installation graphic
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh image-verify-rule.png
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * store all graphics in PPTX
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add validate nested foreach docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * cleanup pass
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update guidance on array values
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * verifyImages revisions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * validate updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh generate
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh variables
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh external data sources
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh preconditions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh autogen
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * edit
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add backgroundScanInterval flag
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh background
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh tips
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh jmespath
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh reports
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh monitoring
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh security
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh cli
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * refresh troubleshooting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * ha updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * release fixes
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add cleanup note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix color of note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add disambiguation into to policy exceptions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * ha refresh
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * ha updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * ha update
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix var in blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove list of all filters and defer to jmespath page
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add time filters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * blog updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * blog update
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update exception guardrails methods
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * make blog a draft
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add CLI and OCI support note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add SLSA 3 blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 17937abe341c20c4ee75d2ba4ee9d54cb5fa6de1[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Jan 17 13:59:25 2023 +0100

    fix: image src in Monitoring docs (#745)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 758996982681ddbb2e03249983879422d4aef9e5[m
Author: Weru <16350351+onweru@users.noreply.github.com>
Date:   Fri Jan 6 17:39:49 2023 +0300

    Style tables in policies' pages (#743)
    
    * wrap tables with styling class
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * restrict page overflow on mobile
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit b9e28e539f3f4dc4e3e831a46782173f8dc06774[m
Author: pealtrufo <32867433+pealtrufo@users.noreply.github.com>
Date:   Mon Dec 26 14:47:29 2022 +0000

    IRSA to access AWS KMS (#699)
    
    Added docs: IRSA to access AWS KMS
    
    Signed-off-by: pealtrufo <32867433+pealtrufo@users.noreply.github.com>
    
    Signed-off-by: pealtrufo <32867433+pealtrufo@users.noreply.github.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4f5a0671b03f42a3d12f0a9e7b0f93daa732922b[m
Author: Steven Lahouchuc <stelah1423@gmail.com>
Date:   Mon Dec 26 09:36:02 2022 -0500

    [1.9] add docs for --audit-warn (#694)
    
    add docs for --audit-warn
    
    Signed-off-by: Steven Lahouchuc <stelah1423@gmail.com>
    
    Signed-off-by: Steven Lahouchuc <stelah1423@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit d48ad236b13a32dd1ed24120da63783e3dd367b4[m
Author: Marc Brugger <github@bakito.ch>
Date:   Mon Dec 26 15:31:53 2022 +0100

    [1.9] feat: allow list with policies in apply (#681)
    
    document example with policies as k8s lists
    
    Signed-off-by: bakito <github@bakito.ch>
    
    Signed-off-by: bakito <github@bakito.ch>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2650dcf0feacd995cf19eb29047d7e17bcf4b238[m
Author: DRAGON2002 <81813720+XDRAGON2002@users.noreply.github.com>
Date:   Mon Dec 26 19:56:00 2022 +0530

    Add `forceFailurePolicyIgnore` flag to installation guide (#659)
    
    add forceFailurePolicyIgnore flag
    
    Signed-off-by: Anant Vijay <anantvijay3@gmail.com>
    
    Signed-off-by: Anant Vijay <anantvijay3@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 81862bbb092bcd5f61dca6f59f1a78e6750ab451[m
Author: yinka <holayinkajr@gmail.com>
Date:   Mon Dec 26 15:22:09 2022 +0100

    add loggingFormat flag to installation guide (#647)
    
    * add loggingFormat flag to installation guide
    
    Signed-off-by: damilola olayinka <holayinkajr@gmail.com>
    
    * move flag to right position
    
    Signed-off-by: damilola olayinka <holayinkajr@gmail.com>
    
    Signed-off-by: damilola olayinka <holayinkajr@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f14aeb994f361de030410082141a5f4f709b7eed[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 14 17:01:01 2022 -0600

    Render policies (#723)
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4d03c03409c88fb13178a4e6edf568c126d82eb8[m
Merge: a898abe9 865db4ee
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 23:19:10 2022 +0100

    chore: minor improvements on main page (#722)

[33mcommit 865db4eea2f6057d593c65394b4f6bb0f4aabc91[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:46:55 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit bdd9de9862d29b76314de5ba617e7edfbd7ca8fa[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:33:04 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 9faaee28a1371a858fec42b145a9f5996ad1144d[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:29:19 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 13c25d80a2835c72c8bd5791648dbd4d93dc6595[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:25:23 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit d0948e58cf1e0606e32f2573076d2a0e99c67596[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:22:32 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit b37b8288585aa6393422fef224f78c03ed40cec9[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:20:49 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit c1ab85e67d449427d11b964e1c6df1169ac1e189[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:18:33 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit d410018ac0455c7bf6691a9129d9b156722d533d[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:11:47 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 94f1bbcb33e0d218beb24a534194b4e98cdc7f6b[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:10:20 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit edb7aea36dbe1a8abaf25db06bc3ea218f411bfa[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:07:54 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit c409cfaf0778e34428ea96df265b0c372987ef3a[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:06:28 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 35f3b7b1bd514cab907058b09fde16c3ff62f5fd[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 14:02:48 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit da54d3826220bb3a092efb0626d5808cbfe8f2e0[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 13:59:40 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 9cbcbf294d29a26e2d157cd9dd41f6300532a73a[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 13:55:53 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 08464418b3bc4293635aff144f6be61ce7dfb80a[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 13:53:19 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit bb6072a94723b25f5de28be36da0cf981a22dbb7[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 13:52:10 2022 +0100

    fix
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 107b6fe963fd1322becf76219a29d1167e0dabc5[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Wed Dec 14 13:46:11 2022 +0100

    chore: minor improvements on main page
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit a898abe91a9ec5a5dd049a8f8757f68ce22f37a2[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Dec 13 15:23:23 2022 +0100

    fix: add smooth scroll (#720)
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit fd003207fd18b17371e111e4519fd2b49317abd2[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Dec 11 23:06:27 2022 -0800

    update videos and blogs (#718)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit f8340b120cd65b9dcc737cf1dbabfb8851597c43[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Dec 10 17:08:24 2022 -0600

    Render policies (#715)
    
    render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 0545f9bdf0eff21853c585f755d124100db69c2f[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Dec 6 12:36:58 2022 -0500

    Renders policies (#710)
    
    * initial rendering
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f2002aa76ce6bcb004ceb3786255f70e340f2ddc[m
Author: weru <16350351+onweru@users.noreply.github.com>
Date:   Sun Nov 13 23:29:04 2022 +0300

    Match exact policy type (#660)
    
    list only exact policy matches
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    Signed-off-by: weru <fromweru@gmail.com>
    Co-authored-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 5c576ce98dae354c47eab14e5999bf7b988c5735[m
Author: Sai Kumar <40134996+saikumarjetti@users.noreply.github.com>
Date:   Sat Nov 12 18:17:50 2022 +0530

    Change link (#691)
    
    * Two Namespace typos fixed in Monitoring page
    
    Signed-off-by: Sai Kumar <saikumar.jetti09@gmail.com>
    
    * Changed policies/pod-security link to homepage of kyverno/policies
    
    Signed-off-by: Sai Kumar <saikumar.jetti09@gmail.com>
    
    Signed-off-by: Sai Kumar <saikumar.jetti09@gmail.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 296544c4fb9e380fd62d60605de75b39e218abbb[m
Author: Sai Kumar <40134996+saikumarjetti@users.noreply.github.com>
Date:   Sat Nov 12 18:14:55 2022 +0530

    Two Namespace typos fixed in Monitoring page (#688)
    
    Signed-off-by: Sai Kumar <saikumar.jetti09@gmail.com>
    
    Signed-off-by: Sai Kumar <saikumar.jetti09@gmail.com>

[33mcommit aedd0e1504522070c91695530fd9adb17eb2e4e1[m
Author: Alex <mythicalsunlight@gmail.com>
Date:   Wed Nov 9 11:39:47 2022 -0500

    Add client-side throttling to troubleshooting docs (#676)
    
    * Add client-side throttling to troubleshooting docs
    
    Signed-off-by: droctothorpe <mythicalsunlight@gmail.com>
    
    * Add client-side throttling to troubleshooting docs
    
    Signed-off-by: droctothorpe <mythicalsunlight@gmail.com>
    
    Signed-off-by: droctothorpe <mythicalsunlight@gmail.com>

[33mcommit eacea1fc8d7a1f075654e04a460f85095afd882a[m
Author: Alex <mythicalsunlight@gmail.com>
Date:   Thu Nov 3 02:57:04 2022 -0400

    Correct clientRateLimit defaults (#674)
    
    Signed-off-by: droctothorpe <mythicalsunlight@gmail.com>
    
    Signed-off-by: droctothorpe <mythicalsunlight@gmail.com>

[33mcommit 48ef1ecf6f84ead46809d72cf5f2dc2b917b52a4[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Oct 24 08:59:31 2022 -0400

    Fix date in blog (#666)
    
    * add release 1.8 blog in draft
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note for OpenShift deployment of Helm chart
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add guidance on variables in Helm
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note clarifying Kyverno CLI binary
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update signature and sbom info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add example on API calls with queries
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * rewrite policy reports
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render check-image-vulns-cve-2022-42889
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify/correct statements on background mode
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix typo, consistency
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix global anchor example result
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update CRD index path
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * publish Kyverno 1.8 release blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix date
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 7ff34ee82208d0de42250032ec23360da6ad9071[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Oct 24 07:48:44 2022 -0400

    Publish Kyverno 1.8 release blog (#664)
    
    * add release 1.8 blog in draft
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note for OpenShift deployment of Helm chart
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add guidance on variables in Helm
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note clarifying Kyverno CLI binary
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update signature and sbom info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add example on API calls with queries
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * rewrite policy reports
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render check-image-vulns-cve-2022-42889
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify/correct statements on background mode
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix typo, consistency
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix global anchor example result
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update CRD index path
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * publish Kyverno 1.8 release blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ab14812b959f7eef09563daa46e367c3f3bf0784[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 21 10:39:03 2022 -0400

    Fix/update language around background scans (#661)
    
    * add release 1.8 blog in draft
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note for OpenShift deployment of Helm chart
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add guidance on variables in Helm
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note clarifying Kyverno CLI binary
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update signature and sbom info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add example on API calls with queries
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * rewrite policy reports
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render check-image-vulns-cve-2022-42889
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify/correct statements on background mode
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix typo, consistency
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix global anchor example result
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update CRD index path
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 9ab8f24c48ab042e3cc77b7ff5508c619fb8e54d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Oct 20 07:48:05 2022 -0400

    Doc updates (#657)
    
    * add release 1.8 blog in draft
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note for OpenShift deployment of Helm chart
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add guidance on variables in Helm
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note clarifying Kyverno CLI binary
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update signature and sbom info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add example on API calls with queries
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * rewrite policy reports
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render check-image-vulns-cve-2022-42889
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b2a5a0209dbda7540203bb1d617a1b649c995bce[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 14 09:32:26 2022 -0400

    Render changes in check-deprecated-apis (#653)
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix policyType
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render check-deprecated-apis
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit be1636dd4f34c4648e9703681fac5f777cabedb5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 14 08:17:07 2022 -0400

    Render policies (#650)
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix policyType
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 43524067bd05132206b4f66fa1628a4bdc779475[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Oct 13 11:03:25 2022 -0400

    render policies (#649)
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix policyType
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 3ab19d42966feae16ad48a1ca212776ab2639bc6[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Oct 13 08:28:42 2022 -0400

    Update release management process (#648)
    
    * render all policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix type
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update config
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update readme with release process
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 049811714986b1b1bbbd978b86d1fed0ce8bf1a7[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Oct 11 15:48:48 2022 -0400

    update prod config (#646)
    
    * render all policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix type
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update config
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ffc5caa103a51c258aa490de7d52d520e9c4ef9d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Oct 11 15:39:54 2022 -0400

    render all policies (#645)
    
    * render all policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix type
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f4018d16c1b8953b143dfc0bba3829090b358f49[m
Author: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
Date:   Tue Oct 11 21:23:23 2022 +0200

    add notes on installing with argocd (#644)
    
    * add notes on installing with argocd
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    * review comments
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>
    
    Signed-off-by: Charles-Edouard Brétéché <charles.edouard@nirmata.com>

[33mcommit 571d723031e72bec692c621f5137738c76dfbb20[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Oct 11 14:58:53 2022 -0400

    More 1.8 docs (#643)
    
    * add initial docs for YAML manifest validation
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add podSecurity docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add deprecation note to splitPolicyReport
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add container flags
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * address podSecurity comments
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Remove unneeded note about annotation secrets
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * catch up on all container flags
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Kyverno compat update
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update docs on aggregated clusterrole
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add OpenTelemetry docs from PR 546
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * incorporate generate CLI docs from PR 603
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * correct auto-gen behavior for JSON patch mutations
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix match example
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add docs on cloning multiple resources
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add x509_decode docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 8ee368b1f741954611bfba65670a429774d97aa6[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Oct 10 15:25:50 2022 -0400

    add podSecurity docs for 1.8 (#637)
    
    * add initial docs for YAML manifest validation
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add podSecurity docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add deprecation note to splitPolicyReport
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add container flags
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * address podSecurity comments
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Remove unneeded note about annotation secrets
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 7b0e1393d848a45a23770d2e4479746fb817c8a9[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 7 20:23:45 2022 -0400

    add initial docs for YAML manifest validation (#635)
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 32e3a8206372bc3fbf9ed25e6ee12cc1815bedbd[m
Author: Santosh Kaluskar <91916466+Santosh1176@users.noreply.github.com>
Date:   Thu Oct 6 23:59:02 2022 +0530

    Add note about immutable Pod fields (#636)
    
    Signed-off-by: Santosh Kaluskar <dtshbl@gmail.com>
    
    Signed-off-by: Santosh Kaluskar <dtshbl@gmail.com>

[33mcommit e171204b102553af09f75233a61b3bc087028180[m
Author: Gurpreet Singh <lostlegend2701@gmail.com>
Date:   Tue Oct 4 18:19:22 2022 +0530

    [Bug] Update Makefile command for building CLI (#631)
    
    documentation_update
    
    Signed-off-by: Gurpreet Singh <lostlegend2701@gmail.com>
    
    Signed-off-by: Gurpreet Singh <lostlegend2701@gmail.com>

[33mcommit 2bd8f598befab801f4eba63a987a4e563a3a52e0[m
Author: Abhilash Raj <maxking@users.noreply.github.com>
Date:   Sun Sep 25 15:42:57 2022 +0530

    docs: Fix the YAML example for keyless signature. (#628)
    
    Remove an extraneous quote.
    
    Signed-off-by: Abhilash Raj <maxking@users.noreply.github.com>
    
    Signed-off-by: Abhilash Raj <maxking@users.noreply.github.com>

[33mcommit 9f61715db3cf6a9589e616aa25aed43c52e641b5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Sep 17 17:24:26 2022 -0400

    1.8.0 updates (#625)
    
    * add docs on using Kyverno CLI in a CI process
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * typos
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * instructions for manual CLI binary installation
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify auto-gen
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add applyRules
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add missing path
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify context variable ordering
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify EKS troubleshooting note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove conflicting statement
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * expand info on --imagePullSecrets
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add/update docs on ClusterRole aggregation changes
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove under construction notice
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add installation note about dedicated namespace
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * cover updates to failurePolicy
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add broken link checker
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note on precondition short circuiting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * newline per comment
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * use env
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note on supported install
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Add CLI test note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * update homepage to incubating
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add info on extended API calls
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove space
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add example of using operator in validate
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix negation anchor description
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add JMESPath random() filter docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add and update flags
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add resources[] and generate to test
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit e2eb571c1b87c37b92e48129188f55832bc8e376[m
Author: Anais Urlichs <33576047+AnaisUrlichs@users.noreply.github.com>
Date:   Sat Sep 17 17:58:18 2022 +0100

    adding YT tutorials from the Aqua Open Source Channel (#621)
    
    Signed-off-by: Anais Urlichs <33576047+AnaisUrlichs@users.noreply.github.com>
    
    Signed-off-by: Anais Urlichs <33576047+AnaisUrlichs@users.noreply.github.com>
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f86ef212b9abc42a3c8a4c99d73f1e88e0710979[m
Author: Dan Garfield <dan@codefresh.io>
Date:   Sat Sep 17 10:56:25 2022 -0600

    Fix check-image cluster policy (#623)
    
    Signed-off-by: Dan Garfield <dan@codefresh.io>
    
    "fail" is case sensitive. Applying the example manifest will fail.
    
    Signed-off-by: Dan Garfield <dan@codefresh.io>
    
    Signed-off-by: Dan Garfield <dan@codefresh.io>

[33mcommit 5b6244ebd923570c82ca702deca6f702cd1aac7b[m
Author: Joe Bowbeer <joe.bowbeer@gmail.com>
Date:   Mon Aug 22 00:05:29 2022 -0700

    fix: Update _index.md (#600)
    
    Update _index.md
    
    Signed-off-by: Joe Bowbeer <joe.bowbeer@gmail.com>
    
    Signed-off-by: Joe Bowbeer <joe.bowbeer@gmail.com>

[33mcommit a2e378e807fba05b5b51e7aedc5dd20e547c4831[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Aug 15 15:08:29 2022 -0400

    add docs on using Kyverno CLI in a CI process; other fixes and updates (#598)
    
    * add docs on using Kyverno CLI in a CI process
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * typos
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * instructions for manual CLI binary installation
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify auto-gen
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add applyRules
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add missing path
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify context variable ordering
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify EKS troubleshooting note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove conflicting statement
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * expand info on --imagePullSecrets
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add/update docs on ClusterRole aggregation changes
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove under construction notice
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add installation note about dedicated namespace
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * cover updates to failurePolicy
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add broken link checker
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note on precondition short circuiting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * newline per comment
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * use env
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 77e63f1c76d9af355f5e21c5d8295c53a4d2f777[m
Author: weru <16350351+onweru@users.noreply.github.com>
Date:   Thu Jul 28 08:24:00 2022 +0300

    extract policy-type after spec declaration (#593)
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit ba6142837f797e44f462a7d21d4edd3b97047c6b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Jul 26 12:20:47 2022 -0400

    Render policies (#591)
    
    * remove package and package-lock
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove stale files
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove reliance upon postCSS so we don't deal with package.json
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render PSA policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4c516558fd7b20ef70198b85388668a0837dbcd0[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 13 20:36:50 2022 -0400

    Render PSA policies (#581)
    
    * remove package and package-lock
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove stale files
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove reliance upon postCSS so we don't deal with package.json
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render PSA policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ad90886f7cec36380807bea1e04e696e5b79e3a3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jul 11 11:01:26 2022 -0400

    Render new policies (#579)
    
    * remove package and package-lock
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove stale files
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove reliance upon postCSS so we don't deal with package.json
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit a5548946289dc77cb464ddc1681739542fbe34dc[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Jul 10 14:52:43 2022 -0400

    remove package and package-lock (#578)
    
    * remove package and package-lock
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove stale files
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove reliance upon postCSS so we don't deal with package.json
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bfd94c5aeb80dd7f80202392fc00865261215a23[m
Author: weru <16350351+onweru@users.noreply.github.com>
Date:   Sun Jul 10 20:43:39 2022 +0300

    Website updates (#574)
    
    * remove docsy as git submodule
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * register docsy as hugo module
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * add tip >> how to update docsy
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * eliminate '.Path' warnings
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * sort filters & trim whitespace
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * correct homepage regression
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * rename home file
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * add blog
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * add top margin clearance for blog
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * update sidebar
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * update heading
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * fix broken search
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * reposition logo & policies
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * update mobile search clearance
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * update sidebar top margin clearance
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * update netlify config & archive previous copy
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * update blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * description change
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * remove old netlify config files
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    * remove docsy submodule cache
    
    Signed-off-by: weru <fromweru@gmail.com>
    
    Co-authored-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bc766e9eb3f301af0aff9b554819a8f363ce52c9[m
Author: Abhisman <53483248+abs007@users.noreply.github.com>
Date:   Sun Jul 10 17:12:19 2022 +0530

    Updated content/en/Community/_index.md (#577)
    
    Fixed the timelines for the community and contributor
    meetings
    
    Signed-off-by: Abhisman Sarkar <abhisman.sarkar@gmail.com>

[33mcommit 010760487c258f91ea5b87317de8bff1a4d10089[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jul 7 12:16:24 2022 -0400

    Render new policies (#573)
    
    * updates for Helm 2.5.0 and Kyverno Namespace exclusion
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * test render
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix validate
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * render new policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2eb6aaa92b3b631681e81e9c335a7e0b07859bbf[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 7 08:20:33 2022 -0700

    add cherry pick and release planning details (#567)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit e009f1f9d3fda598022cae23f1680286cc9cba4b[m
Author: Rafael Ceccone <ceccone@users.noreply.github.com>
Date:   Wed Jul 6 14:16:54 2022 +0200

    fix link for mutate existing resources (#572)
    
    Signed-off-by: Rafael Ceccone <rafael@ceccone.net>

[33mcommit a61c977507f524a930c0bed23c6bd08245511313[m
Author: Marcelo Moreira de Mello <tchello.mello@gmail.com>
Date:   Tue Jul 5 11:38:58 2022 -0400

    Clarifying `autoUpdateWebhooks` behavior on docs (#570)
    
    * Clarifying `autoUpdateWebhooks` behavior on docs
    
    Signed-off-by: Marcelo Moreira de Mello <tchello.mello@gmail.com>
    
    * Update content/en/docs/Installation/_index.md
    
    Signed-off-by: shuting <shutting06@gmail.com>
    
    Co-authored-by: shuting <shutting06@gmail.com>

[33mcommit af23aa521fac8a55e1ae29b8bc8c68b6ea6d50fb[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jul 3 12:20:53 2022 -0700

    59 fix render (#568)
    
    * fix render issues
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * render latest
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * fix linter issues and revert policy type
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 287e2809f6e07fc03d24dbd6867450335e5ad1c3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jun 9 11:55:30 2022 -0400

    updates for Helm 2.5.0 and Kyverno Namespace exclusion (#563)
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit a8e181c058b8b44e33ab5d7d4f239dc148488415[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Jun 8 04:37:22 2022 -0700

    fix example policies (#560)
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit fa01c25a10c03f9f6f79ce972580f767357d0d87[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Jun 7 11:14:21 2022 -0400

    More 1.7.0 doc updates (#557)
    
    * add docs on items() and object_from_list() filters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * typo
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add cross-link
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * test command rewrite
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add missing test result of warn
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add info on policy
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * Update signature verification method to use keyless
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add foreach note about array of strings
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note about issuer and subject
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add note about docker official images in imageData
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add disclaimer
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * three => four
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit fa189d80d87f527a03cd6229b0795ac6cf57f385[m
Author: weru <16350351+onweru@users.noreply.github.com>
Date:   Mon Jun 6 17:57:27 2022 +0300

    Make filter matches case insensitive (#558)
    
    make filters matching case-insensitive
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit fa7938b708a9c2ba1b5e96d54053b4a2c328f3e3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Jun 5 16:04:52 2022 -0400

    [1.7.0] Add cross-link, re-write test docs (#556)
    
    * add docs on items() and object_from_list() filters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * typo
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add cross-link
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * test command rewrite
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add missing test result of warn
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add info on policy
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bea34ab868c4c91e87aa543856cf8813f700e147[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jun 4 13:12:19 2022 -0400

    [1.7.0] Add docs on `items()` and `object_from_list()` JMESPath filters (#554)
    
    * add docs on items() and object_from_list() filters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * typo
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit d670ecfa26702b7ca5a5aecf27420f9759b6e1e9[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 14:02:17 2022 -0400

    Add Nirmata blog on Kyverno v1.7.0 release (#552)
    
    * fix returning to latest release from main
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add Nirmata 1.7.0 release blog post
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 536328e38ac52d38d26d55f87ce064dc3333a007[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 12:18:54 2022 -0400

    fix returning to latest release from main (#551)
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 0d757a7556b92099f14c87c1d3fefc5c4bd6235e[m
Merge: 87dad42a 9b842437
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 11:51:29 2022 -0400

    Merge pull request #550 from chipzoller/main
    
    Adds release version

[33mcommit 9b8424378b4623d4984071b5ebb06b729af4b95b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 11:32:45 2022 -0400

    add version to config
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 87dad42a81831b58afd06d55730f47d9fa393c77[m
Merge: 6dcc9a42 509dab73
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 11:26:07 2022 -0400

    Merge pull request #548 from chipzoller/main
    
    1.7.0 doc updates

[33mcommit 509dab73be407d52bf237416f294a058d00c05b9[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 11:24:21 2022 -0400

    Show example of reference other variables
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 3f68311543a3e77b2d730b7570d5b00b8b100429[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 11:22:13 2022 -0400

    add sentence about variable redefinition
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 41ddd7d3a431c2aff42e3c4bd1be198ee7f3a58b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 11:20:49 2022 -0400

    add note on value field not being defined
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit e06a1510690d19eb2baf18f8b32ea85d1c9a057c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 11:11:43 2022 -0400

    capture all variants of vars
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 78b67b3d46784eda0b006aa85ffa02e78bd49534[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 11:01:11 2022 -0400

    expand comment
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5243fabf456ef144b8709e2752ffbba934d14660[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 10:59:05 2022 -0400

    capture note on default value resolution
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5a88de4046cddd261c3b1a38d0d569301f9a0939[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 10:53:47 2022 -0400

    manually copy content from 733be7c to main
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f7c11f0dfa580985538cd1315ce302ca2d40de72[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 10:11:19 2022 -0400

    remove note on validate sub-command
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ae3759f1b7f50cbac99a8af5f19ea9f9fc188bee[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 10:06:45 2022 -0400

    update tests section
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b503012bd8bcf245e3e04bbb6da42ca7620f0a6d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 09:54:02 2022 -0400

    manually add apiVersion
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4183b8aa99a76e16071731aab6e36fa432cc3ca7[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 09:53:14 2022 -0400

    manually fix rule type
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 0435147c40b0232fb2fa559926a7d9a6b8e008fd[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 09:46:09 2022 -0400

    add apiVersion to all generate examples
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit dc58c3febeedcd00a55fdb219de6ac72807f05b6[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 09:42:32 2022 -0400

    add inline variable context info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 3ab86bb67ca9f6fc3e47bc5df2382081a62f4426[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 09:28:06 2022 -0400

    remove YAML multi-line info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6bf0ef23aa2dcb0acca352be79156d66658a6eba[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 09:21:20 2022 -0400

    add cli jp -f flag enhancements
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 840dbb61736401e09190ef66b65dc3d613577cd8[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 09:14:26 2022 -0400

    add cert rotation notes
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit fba46d454a5b5bf0dd6c39d38a6ea74d7b04fb18[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 09:10:34 2022 -0400

    add sub-resource info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 8df78aea70480446e7a7f327a5b1b746600e1379[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 09:04:23 2022 -0400

    linting, typos, and command to decode atts
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f12211fcd174025377920586c005cdd56fd740a2[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 08:43:47 2022 -0400

    document --allowInsecureRegistry container flag
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bc77164417f46bf1a1c2f226d0bafc0ccddff7a0[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Jun 3 08:39:08 2022 -0400

    document --autogenInternals
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6dcc9a42fc1bf481d5c054548d680dc79b453867[m
Merge: 64e21b07 12a76bef
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jun 2 21:18:17 2022 -0400

    Merge pull request #545 from chipzoller/main
    
    Render all policies

[33mcommit 12a76bef71854cca8ac685c56da7bea0d3484b0c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jun 2 21:01:36 2022 -0400

    remove duplicate "show"
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2d141a18b565fddd88cd9591f1bb1a79d28f550c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jun 2 20:52:58 2022 -0400

    render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b5d9ab27f26c530b72a1cca29039d5319d9990fc[m
Merge: 5ba84ec9 64e21b07
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jun 2 13:38:06 2022 -0400

    Merge branch 'kyverno:main' into main

[33mcommit 64e21b071cccfc33d90f3c1206c9ff3cbbe9b655[m
Merge: 36b6a6d3 fab25b33
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jun 2 08:42:08 2022 -0400

    Merge pull request #508 from 4molybdenum2/admission-info-doc
    
    add docs for support for roles, cluster roles and subjects in CLI

[33mcommit 36b6a6d3a0e2ca8afc203ef113670cc55bb0905d[m
Merge: 545b4fcd 620d6ba6
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jun 2 08:41:30 2022 -0400

    Merge pull request #539 from kyverno/1.7_image_signing
    
    update image signing for 1.7

[33mcommit 620d6ba6a12e5fbc166602209ac59734832675aa[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Jun 1 20:50:53 2022 -0700

    address comments
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 545b4fcd1991378c3e0c2fdc8347ae3df5ba58be[m
Merge: 59afeac8 377cf3b5
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jun 1 21:35:16 2022 -0400

    Merge pull request #543 from kyverno/add_webhooktimeout
    
    Add webhookTimeout

[33mcommit 377cf3b5f4a6fc4569232143b3bbef182064da75[m
Author: ShutingZhao <shuting@nirmata.com>
Date:   Thu Jun 2 00:52:08 2022 +0800

    Updates webhookTimeout container flag
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit e9113fe880c4adb2d21a15e2ebe9631844476ecc[m
Author: ShutingZhao <shuting@nirmata.com>
Date:   Thu Jun 2 00:51:38 2022 +0800

    Adds webhookTimeout container flag
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 59afeac8ef481db9881eb19b3f867152129e4c2b[m
Merge: a56cf447 90fbce64
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jun 1 11:48:14 2022 -0400

    Merge pull request #542 from prateekpandey14/add-generate-existing
    
    Add docs for generate policies on existing resources

[33mcommit 90fbce644ddb555613f367bbde8172b396086831[m
Author: prateekpandey14 <prateekpandey14@gmail.com>
Date:   Wed Jun 1 21:08:07 2022 +0530

    add new line and remove deprecate msg from sub-title
    
    Signed-off-by: prateekpandey14 <prateekpandey14@gmail.com>

[33mcommit 2d16b7cee27feeece39fc065657e5d289da87106[m
Author: prateekpandey14 <prateekpandey14@gmail.com>
Date:   Wed Jun 1 20:21:35 2022 +0530

    fix additional review comments
    
    Signed-off-by: prateekpandey14 <prateekpandey14@gmail.com>

[33mcommit dd69805c01002c60301b1f89a4495a0eb9b30ecf[m
Author: prateekpandey14 <prateekpandey14@gmail.com>
Date:   Wed Jun 1 18:45:33 2022 +0530

    fix further review comments
    
    Signed-off-by: prateekpandey14 <prateekpandey14@gmail.com>

[33mcommit 616f23856a0250143aacbb6753299ce821280721[m
Author: prateekpandey14 <prateekpandey14@gmail.com>
Date:   Wed Jun 1 13:42:17 2022 +0530

    fix review comments and refactor the content
    
    Signed-off-by: prateekpandey14 <prateekpandey14@gmail.com>

[33mcommit db57a1204d1c503b75d0935040a0ac5600bb81d3[m
Author: prateekpandey14 <prateekpandey14@gmail.com>
Date:   Wed Jun 1 10:37:18 2022 +0530

    Add docs for generate policies on existing resources
    
    Signed-off-by: prateekpandey14 <prateekpandey14@gmail.com>

[33mcommit a56cf44743cff5f528bab4ee3666ef09a75678a8[m
Merge: 652dd83f dd8b1b25
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue May 31 10:44:09 2022 -0400

    Merge pull request #541 from 4molybdenum2/fix-example-match-resources
    
    Fix missing hyphen (-) in doc

[33mcommit 652dd83fdd95ef88672962d2850f891621a9bdda[m
Merge: 6301a958 4e18ad2a
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue May 31 10:43:22 2022 -0400

    Merge pull request #540 from kyverno/add_mutate_existing
    
    Add mutate existing docs for 1.7.0

[33mcommit dd8b1b25ccdacc91ffbcc7a0594d07ea81f0effb[m
Author: Tathagata Paul <tathagatapaul7@gmail.com>
Date:   Tue May 31 20:08:24 2022 +0530

    fix example in match-exclude documentation
    
    Signed-off-by: Tathagata Paul <tathagatapaul7@gmail.com>

[33mcommit 4e18ad2aef0d3efbd91b27459e0a1f37393f5df5[m
Author: ShutingZhao <shuting@nirmata.com>
Date:   Tue May 31 22:36:57 2022 +0800

    Address additional comments
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit d75dd373e952c576d2125d23dc55104840eeefd1[m
Author: ShutingZhao <shuting@nirmata.com>
Date:   Tue May 31 20:34:21 2022 +0800

    Resolve comments
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 9f95838790975e85e045a63def98bf8b49e59241[m
Author: ShutingZhao <shuting@nirmata.com>
Date:   Tue May 31 17:40:27 2022 +0800

    Add doc for mutate existing policies
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 9bad12a517179652dd5312db01fafe4507edcf82[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun May 29 16:32:54 2022 -0700

    update image signing for 1.7
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit fab25b33db59c08b9487f4a2f3c7ac7aed0e14e7[m
Author: Tathagata Paul <tathagatapaul7@gmail.com>
Date:   Sun May 29 11:57:38 2022 +0530

    fix typo
    
    Signed-off-by: Tathagata Paul <tathagatapaul7@gmail.com>

[33mcommit 6301a958e738c2edbccd4223554ff22c99982b1e[m
Merge: 84b72c66 a06f3059
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat May 28 19:17:24 2022 -0400

    Merge pull request #500 from vyankyGH/deprecate_validate_cmd
    
    removing validate cmd

[33mcommit 5ba84ec9cac1b43be45eb0397ff2d7fda303ed36[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri May 27 08:21:37 2022 -0400

    fix expression
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 84b72c6681f7c7c10eef71d63ee4faee267ddc66[m
Merge: 62b1fad7 d8f75d7d
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed May 25 12:39:20 2022 -0400

    Merge pull request #515 from chipzoller/main
    
    1.7 updates

[33mcommit d8f75d7d2b4bf660199199c766ef999b2fecbbb9[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon May 2 07:43:30 2022 -0400

    comment
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b9894e0ed3a3bbb94eb25f06a5ed6657073116d1[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun May 1 19:04:40 2022 -0400

    linting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6aa4849315ec5f50d2f5283ff6f6e6ac6497cfe5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun May 1 14:28:18 2022 -0400

    link from wildcards
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit c93b8dfea13ad6cd074955447a93ad3f5dc4c623[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun May 1 12:37:15 2022 -0400

    add section on matching wildcards in JMESPath
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b8bcd17c1ac55cbe719cd2ea917d7ca70ff09702[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Apr 30 14:45:21 2022 -0400

    add autogen metadata escape trick
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 1f413ff4a473d42496b986920a8ea43186f0edd4[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Apr 29 11:11:39 2022 -0400

    clarify note
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 47a2a3e1f8c3be1dab5cffc2646d7716e2757862[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Apr 28 08:23:38 2022 -0400

    fix broken links
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit dd83b20fe7a44ecd728624a15ef167b733928ac4[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Apr 27 10:32:56 2022 -0400

    re-render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit de9b358b1df0d7bac68948eaaf97d146566a01ac[m
Merge: 5ad9dc6c 62b1fad7
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Apr 27 10:28:41 2022 -0400

    Merge branch 'kyverno:main' into main

[33mcommit 5ad9dc6c201255a67a69a76c83fbaf2b8aef0930[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Apr 27 10:28:15 2022 -0400

    Revert "render policies"
    
    This reverts commit 507159c12551d993538eaa89fab62aa9ca3c2b62.

[33mcommit 507159c12551d993538eaa89fab62aa9ca3c2b62[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Apr 27 08:24:38 2022 -0400

    render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 787c6e4d530194057d5cdbcf86b3e0df209d67dc[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Apr 27 07:16:13 2022 -0400

    note about namespace or object selector
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6ac3a8fcefac3c46e85dd7d585a88d7b86a524ec[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Apr 26 20:42:51 2022 -0400

    clarify and consolidate inoperability sequence
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 62b1fad74bbd1b281056298ba9d586ae468844a7[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Apr 25 12:25:22 2022 -0700

    fix typo
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 74d161cfce163b90cb59e2fec4f074b31331b582[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 25 15:13:25 2022 -0400

    address comments, improvements
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 898e63d00c048f0462788ff25eb752f73b81d49a[m
Merge: 4f40e317 66635cc2
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 25 13:33:44 2022 -0400

    Merge pull request #521 from JimBugwadia/render_policies
    
    Render policies

[33mcommit 66635cc2d71dbcc75609cb806d57b109afc6b9bd[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Apr 25 10:28:03 2022 -0700

    render policies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 102504b4bc42575a9345a5e1abc0f296523f342c[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Apr 25 09:50:59 2022 -0700

    update version
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit a745593b0a7b164d3916d28e3c6f00d0849496cc[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 25 09:21:10 2022 -0400

    polish guidance on exclusions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f85f447544df5011b34a171bd617c9825a297bde[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Apr 21 17:25:31 2022 -0400

    mode => replicaCount
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4f40e317bc3c13d030adbc859db40814f43e3455[m
Merge: bb534c92 49071c68
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Apr 19 15:41:33 2022 -0400

    Merge pull request #517 from treydock/imageData-private-reg
    
    Document imageData policies can also use private registries

[33mcommit 49071c6828ccf744e43db80079793db9e3cbf1a7[m
Author: Trey Dockendorf <tdockendorf@osc.edu>
Date:   Tue Apr 19 13:55:07 2022 -0400

    Document imageData policies can also use private registries
    
    Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>

[33mcommit 155869f71dcb10d3c6c2c6fab657e6402819bbbd[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 18 18:14:40 2022 -0400

    add clientRateLimit* container flags
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4d46a8689822acb5cc003359fde7970ff4912f6b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 18 18:11:16 2022 -0400

    add CLI test namespaceSelector in variables
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5352dd331fe3cc295e6fafc7141532150f30df41[m
Merge: a1fae46f bb534c92
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 18 17:36:33 2022 -0400

    Merge branch 'kyverno:main' into main

[33mcommit a1fae46f1f64a3c8f39fe45fa49acffdb77e61c8[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 18 17:35:59 2022 -0400

    1.7 updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bb534c92b31d745eea795ebb0c7239be68cec979[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 18 13:08:33 2022 -0400

    JMESPath updates (#504)
    
    * add base64_encode filter
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix compare() return type
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add compare() function doc
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add divide() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add equal_fold() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add label_match() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add modulo() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add multiply() docs and minor bumps to other arithmetic filters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix expansion
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add break
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add parse_json() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add pattern_match() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add split() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add truncate() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add trim() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * clarify and fix trim()
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add regex_match() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add to_upper() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add to_lower() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix end tag
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add time_since() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * address input from Marcel
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add subtract() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add semver_compare() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add replace_all() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add replace() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add regex_replace_all() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * add regex_replace_all_literal() docs and fix other
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * address comments
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bd640dc6906d225b681f3c4baf8962d53e9ea8d5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 18 13:07:50 2022 -0400

    address comments
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 46e43a736b493fe686a1e7dc8c28bf07e5957af3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Apr 17 10:33:46 2022 -0400

    add regex_replace_all_literal() docs and fix other
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit c8df61dadb19192217d79c52d5d6024a985f6c2a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Apr 16 13:51:41 2022 -0400

    add regex_replace_all() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2afde05d159fe6f7affbbb9731bf90cc69bd94b4[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Apr 16 12:32:19 2022 -0400

    add replace() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 30ac01026d3a17350e66ba67e2b0de25e4ddced1[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Apr 16 11:04:49 2022 -0400

    add replace_all() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 7e756e9fab59a1c3ef23392a8bffc83cdf405c70[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Apr 16 10:25:42 2022 -0400

    add semver_compare() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit fa321854b92609d8c51bdb011f9ce517d37a0fbe[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Apr 14 21:12:29 2022 -0400

    add subtract() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b556df1253f184677ed7bcc3fce7f324f39f7d81[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 11 12:29:17 2022 -0400

    address input from Marcel
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit e39f27da0670c552f15cbc1102f13760eed27975[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 11 10:22:20 2022 -0400

    add time_since() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit dabaa5b7800ed945948ac31229bdedb2e340003d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 11 09:17:44 2022 -0400

    fix end tag
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 81660e44ca3b23dc7f4dd8f54b28bc320e9f4626[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 11 08:56:21 2022 -0400

    add to_lower() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5613a59902dcb0f9ea9da9668b78b2d062fcbb60[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 11 08:48:48 2022 -0400

    add to_upper() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4df581618a9d34e7f05c50b79a72377f2a1e1c13[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 11 08:10:34 2022 -0400

    add regex_match() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 3b89ae5f45d81232462a60ca13e975f36378a8d4[m
Merge: 0e4004d8 f523f20c
Author: shuting <shutting06@gmail.com>
Date:   Sat Apr 9 19:02:43 2022 +0800

    Merge pull request #511 from kyverno/add_slides

[33mcommit f523f20c8caeb91bf1960e0fb4d35b690fa25c33[m
Author: ShutingZhao <shuting@nirmata.com>
Date:   Sat Apr 9 18:52:51 2022 +0800

    add new slides
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 0e4004d8eb72acc726969ee59f070a42122d3e74[m
Merge: 527d3d3c ab331a61
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Apr 7 11:48:36 2022 -0400

    Merge pull request #510 from kyverno/out_boarding
    
    Add off-boarding guidance

[33mcommit ab331a613ed6579154dc84fb525d24e283d43f48[m
Author: ShutingZhao <shuting@nirmata.com>
Date:   Thu Apr 7 23:46:44 2022 +0800

    add off-boarding guidance
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 872fd4261266276393dcaef160454fad11d2bc86[m
Author: Tathagata Paul <tathagatapaul7@gmail.com>
Date:   Wed Apr 6 13:52:41 2022 +0530

    add docs for support for roles, cluster roles and subjects in CLI
    
    Signed-off-by: Tathagata Paul <tathagatapaul7@gmail.com>

[33mcommit 3a17de00049f256b8dd439c141ebbe15a2c2efe3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Apr 5 18:17:17 2022 -0400

    clarify and fix trim()
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 64a6ba5f8135a5c357c142d1adf9594bbc37848f[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Apr 5 13:01:12 2022 -0400

    add trim() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f482e2951981629495439a364bfe8b2ab6b6f0a2[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 4 13:57:10 2022 -0400

    add truncate() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5b8530a3d39bf56f3f6c53deb6cd50f003930915[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Apr 3 19:43:19 2022 -0400

    add split() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5e733172c267bc4777c7360ba7fd7784f1de9089[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Apr 3 18:11:32 2022 -0400

    add pattern_match() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 37e433b58856abfec6c91885fd577fefd80992bf[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Apr 3 09:59:52 2022 -0400

    add parse_json() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 371d281aaed6b36fe35dcbd686b63cd04c280db2[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Apr 3 09:08:40 2022 -0400

    add break
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6a29763ff062018880e872ba0d3b629a1516fe72[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Apr 3 09:00:36 2022 -0400

    fix expansion
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b36771a76ad5de69d277d8f96d4b1b2bb5bf4a8c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Apr 3 08:56:13 2022 -0400

    add multiply() docs and minor bumps to other arithmetic filters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4979e7b33d5df8827e539de7854a90b41ea62f8b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Apr 2 19:14:47 2022 -0400

    add modulo() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 86020c022e9c764d8d299ad89c049f850ef157da[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Apr 2 08:02:41 2022 -0400

    add label_match() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2218f5f8b09b100a29707b96ff472072c7018026[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Apr 1 15:36:57 2022 -0400

    add equal_fold() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4f178addd429c01ca90ee658b48bcc63a5d28c29[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Apr 1 10:47:58 2022 -0400

    add divide() docs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 54f7359b06f84acffaa40ef15c5ffc37b5393dca[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Mar 31 19:52:21 2022 -0400

    add compare() function doc
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit df595a8c430a58a29bb83c97dea429d718bb24e2[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Mar 31 18:56:52 2022 -0400

    fix compare() return type
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 48350b60126298431676765cd58276c2a3fda205[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Mar 31 18:38:39 2022 -0400

    add base64_encode filter
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit a06f30597c361e8b4e91c07d99ee8d8211c589da[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Mon Mar 28 10:45:25 2022 +0530

    Deprecated validate cmd

[33mcommit 527d3d3cbecdcdbf50a5a4e34938b0ab803bbd8d[m
Merge: 5fd95894 f306808f
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Mar 25 09:41:08 2022 -0400

    Merge pull request #497 from vyankyGH/wildcard_update
    
    Wildcard update

[33mcommit f306808f9309dde7c5943e45cac9629015f247ea[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Fri Mar 25 19:10:15 2022 +0530

    addressed comment

[33mcommit f6cc50b13637257c6275348afd63ce0b2c70f64a[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Fri Mar 25 18:53:26 2022 +0530

    fix comment

[33mcommit 7fc532f4e7112e699066aa773105ed1faea0bd29[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Fri Mar 25 17:03:16 2022 +0530

    Update match-exclude.md

[33mcommit 330202e4b609804fd089ca5bd27e1f8561d1a625[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Fri Mar 25 17:02:45 2022 +0530

    update wildcard policy support

[33mcommit 5fd958942f4ab620e4aeaec61b852af1e1c6d719[m
Merge: bf000554 1d56a4a4
Author: shuting <shuting@nirmata.com>
Date:   Mon Mar 21 14:59:29 2022 +0800

    Merge pull request #493 from chipzoller/main
    
    add enhancement issue template; fixes and additions

[33mcommit 1d56a4a4f41e16ff5c3f3b2256fcdea9a1260135[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Mar 20 08:52:47 2022 -0400

    fix indentation
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit db80c0616e08833f5e7475c0f04428d310c12886[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Mar 19 19:32:50 2022 -0400

    add new troubleshooting step for EKS users
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b2003c6ca0401ed1258fd88e6b2a2fe48123731e[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Mar 19 19:26:42 2022 -0400

    Clarify variables support context entries
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 9a5d9a5e39e89e1ac842b331c90d194e91474fdd[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Mar 19 19:17:35 2022 -0400

    add globalValues section to test variables file
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit c861aa8df3afbd32460d55d3b2967740456b39cb[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Mar 19 18:49:30 2022 -0400

    add enhancement issue template
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bf000554346c1763abc0a6fcdd8e81b03f3d2459[m
Merge: bc4c364a 3cdd957d
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Mar 12 16:19:22 2022 -0500

    Merge pull request #483 from JimBugwadia/render-030922
    
    render policies

[33mcommit 3cdd957de155513d6c5032db06dded382e4a1e88[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Mar 12 00:29:34 2022 -0800

    add versions
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit c249b3d8a37633642497683afc2027cff85ed8fe[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Mar 11 09:14:48 2022 -0800

    remove sp
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 20856cb0f6af54c00da48a017374552149497134[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Mar 11 09:12:51 2022 -0800

    revert to NotIn
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 247ebe8cf537147d59e9699e9371d8d735916928[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Mar 10 23:07:40 2022 -0800

    re-render
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit bb2003763ef5e6bc1e9fd3205075453c2a9768fd[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Mar 9 17:11:50 2022 -0800

    render policies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit bc4c364af15232b23ca38e6031bbd116f5c3bca2[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Feb 19 10:24:04 2022 -0500

    [main] 1.6 updates (#477)
    
    * save
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * use pageinfo shortcode for policies page
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix space
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * reswizzle custom cert instructions using step
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * fix and clarify new operators
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * 1.6 updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>
    
    * 1.6 updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 18de3bdfbd7d0e14d22c120e4dd5e0bebc1baa76[m
Merge: 25573161 6f088216
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Feb 12 09:50:15 2022 -0500

    Merge pull request #474 from chipzoller/main
    
    adopt github issue forms

[33mcommit 6f08821667c5fd92c2c2118be0008789ab82fb24[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Feb 12 07:31:21 2022 -0500

    rename
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6d41e3196163ebebb2e0f3c5ad8074a6c5368fd7[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 11 21:01:14 2022 -0500

    update
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2df49bf7038201a02db4963f755ab9a6d2093259[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 11 20:48:56 2022 -0500

    updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit defc357c1d6c84b753a7cf869a1749d63b7d1fd5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 11 20:41:07 2022 -0500

    updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit cf984b9135131dc6a0a38e305ad97f878957399b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 11 20:37:02 2022 -0500

    updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 814d891b970fa894f7d7e672193814371b166070[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 11 19:42:33 2022 -0500

    rename, update PR template
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 574b849d931121078003a7b6153ff8e027a2c2ac[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 11 19:37:18 2022 -0500

    adopt github issue forms
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 25573161d3a23f94486b033e896810b78caed7ab[m
Merge: 3282e294 01dce9db
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 11 09:49:28 2022 -0500

    Merge pull request #472 from chipzoller/main
    
    JMESPath doc updates; render policies

[33mcommit 01dce9db3dcff89eeddb59f7eadff4263c902d74[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 11 08:19:59 2022 -0500

    render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4a924e3081512595d2f88ca8c7aa571aaa9da168[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Feb 10 20:52:13 2022 -0500

    update
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 3282e2949188ca72ded5764ab633446b8e0fbbe3[m
Merge: df6ba0ed a0c3063f
Author: Sambhav Kothari <sambhavs.email@gmail.com>
Date:   Thu Feb 10 06:49:01 2022 +0000

    Merge pull request #469 from chipzoller/main
    
    Minor doc updates

[33mcommit a0c3063f0f7f5e6844c295222201dbfd6604ea64[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Feb 9 20:13:55 2022 -0500

    write flatten array
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f08979c80de1bc7c1a612235c2b30093debed90c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Feb 9 16:41:21 2022 -0500

    jmespath updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 03d4227e851e7a8a51572410ef02a429f5e33387[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Feb 8 17:23:56 2022 -0500

    add reminder about clearing Netlify cache
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 42ff2954ad00ae396c47fad138d426d50b39e7ee[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Feb 8 17:21:41 2022 -0500

    address earlier PR comments
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit df6ba0edb4ad7a1260066ef1f0ae2db168075c50[m
Merge: 0b2e9b4a 543fa45e
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Feb 8 14:03:09 2022 -0800

    Merge pull request #468 from chipzoller/main
    
    add 1.6.0 release to menu in main

[33mcommit 543fa45e8744467cf084c6eede7364f751b97dbf[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Feb 8 15:01:41 2022 -0500

    add 1.6.0 release to menu in main
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 0b2e9b4a28425393828eb659ad7609cc3c6d6029[m
Merge: 819529e5 b51f5313
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Feb 8 14:26:59 2022 -0500

    Merge pull request #466 from chipzoller/main
    
    1.6.0 updates

[33mcommit b51f53138ce7fc279e86b883a99e442843ad8188[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Feb 8 11:53:10 2022 -0500

    address comments
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6a79c96e828fbe8fef234fe8a377c8640334f033[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Feb 8 10:44:13 2022 -0500

    expand jmespath
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 01751ac89374e48f23a5aa139402b5a6bdb95ace[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Feb 7 20:11:47 2022 -0500

    add kyverno jp section
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 15d986dcae1a5ab02cba30163126ba4221386f32[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Feb 6 19:31:12 2022 -0500

    fix typos
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 3279396f22a08c804c2ff57230634721d2696703[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Feb 6 18:32:27 2022 -0500

    updates for 1.6.0
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 35915be70f1f5a22c2205e32b6e21dd9d2db30ff[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Feb 5 08:30:44 2022 -0500

    render latest policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 819529e5897c6621d51de1033923e87181653676[m
Merge: c66878fa 555495fa
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Feb 5 08:11:32 2022 -0500

    Merge pull request #453 from ojhaarjun1/tmp-ns-failaction
    
    Namespace Specific ValidationFailureAction

[33mcommit c66878fadb48df9c0dec0701e294b722162e4f96[m
Merge: d2001549 b4825f0f
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Feb 5 08:10:36 2022 -0500

    Merge pull request #454 from ojhaarjun1/jmespath-arithmetic-units
    
    Update JMESPath arithmetic functions' docs

[33mcommit 555495fa9b31e4b41cb74ed2fdffb34bb98b18b6[m
Author: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>
Date:   Sat Feb 5 17:40:59 2022 +0530

    Added inline comments to the example
    
    Signed-off-by: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>

[33mcommit b4825f0fe7b186b30e55d67f8869cbeb29c9c649[m
Author: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>
Date:   Sat Feb 5 17:32:41 2022 +0530

    Add note for parameter types
    
    Signed-off-by: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>

[33mcommit d2001549340d47efb75aa8491435abdb891aefd7[m
Merge: 664b4e3f a57f7273
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 4 20:22:25 2022 -0500

    Merge pull request #465 from JimBugwadia/fix-threat-model-headers
    
    remove links from headers in security section

[33mcommit a57f727309c4d7f6b9416f1e0686e731d1676299[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Feb 4 17:20:12 2022 -0800

    pull up networking
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit d81e91d6eb5a404d680f5196db1b01d11a7907f3[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Feb 4 16:47:03 2022 -0800

    remove links from headers
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 79c7791e7bdfd4c9baf4f4774879c28c20700ddd[m
Author: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>
Date:   Thu Jan 27 19:55:59 2022 +0530

    Fix typo
    
    Signed-off-by: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>

[33mcommit ed11f8fa5df8d6e6d112240c140d7311fa25dfe4[m
Author: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>
Date:   Thu Jan 27 19:53:55 2022 +0530

    Fix typo
    
    Signed-off-by: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>

[33mcommit 98065ebefd066cdc8d8be28eb6fdb4b5265a2807[m
Author: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>
Date:   Thu Jan 27 19:13:30 2022 +0530

    Update JMESPath arithmetic functions' docs
    
    Signed-off-by: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>

[33mcommit 664b4e3fc455d2205cac11a35c6ac0c76dbf2a38[m
Merge: 91cf5ace 72d9c071
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Feb 3 08:36:37 2022 -0500

    Merge pull request #462 from JimBugwadia/main
    
    update releases

[33mcommit 72d9c071df4a352c05c543f857cd8fa8e6b212f0[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Feb 2 11:02:15 2022 -0800

    update releases
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 91cf5ace99b5290fdd1d15957c1dca79e06cf3a9[m
Merge: 35a87ace c47ac090
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Feb 1 07:41:07 2022 -0500

    Merge pull request #408 from Danny-Wei/add-jmespath-function-path-canonicalize
    
    document path_canonicalize custom JMESPath function

[33mcommit c47ac090eb14a2bdc0c297927c138363557004d8[m
Merge: ee8b2010 35a87ace
Author: Danny__Wei <11975786+Danny-Wei@users.noreply.github.com>
Date:   Tue Feb 1 10:42:43 2022 +0800

    Merge branch 'main' into add-jmespath-function-path-canonicalize

[33mcommit 35a87ace349ff53ad8475514beb83de1174b922e[m
Merge: cea5051d 3accb21a
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 31 10:02:19 2022 -0500

    Merge pull request #433 from samj1912/patch-1
    
    [1.6.0] Add `parse_json` to the list of custom JMESPath functions

[33mcommit cea5051de51d2760e7b7b8a8ad845cf968c3c006[m
Merge: 68a71c7a fe3d1723
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 31 10:01:24 2022 -0500

    Merge pull request #353 from anushkamittal20/new-operators
    
    [1.6.0] Added doc for new operators

[33mcommit 3accb21acd08be3f3252e661f6ebe30bf2d01c21[m
Merge: 7ba80db7 b17d2b9b
Author: Sambhav Kothari <sambhavs.email@gmail.com>
Date:   Mon Jan 31 14:59:49 2022 +0000

    Merge branch 'main' into patch-1

[33mcommit 68a71c7a9bb613d36f3cb2b00cf9e0c9765081ce[m
Merge: b17d2b9b e9f08cd8
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 31 09:59:49 2022 -0500

    Merge pull request #363 from ljakimczuk/feature/range-operator
    
    [1.6.0] *Range operators

[33mcommit b17d2b9b2c619ae0c43acde9760728d1f676a91c[m
Merge: 7fe151fe 42b7b1ef
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 31 09:56:50 2022 -0500

    Merge pull request #391 from bastjan/add-pattern-match-jmespath-function
    
    [1.6.0] Document `pattern_match` JMESPath custom function

[33mcommit 7fe151febd43b93eadf440f5239d8c6805950eb7[m
Merge: ef123d29 4da7a5ca
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 31 09:55:38 2022 -0500

    Merge pull request #418 from zeborg/cli-git-path-dir-branch
    
    [1.6.0] Updated docs for `kyverno test` command with git path

[33mcommit ef123d296dca2f3a8f434a548f9ff976ac329130[m
Merge: f18305ff ab9552e5
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 31 09:53:06 2022 -0500

    Merge pull request #429 from dkulchinsky/dannyk/truncate_docs
    
    document custom JMESPath truncate function

[33mcommit f18305ff9809fb9f2623c60efcf8049cd07161f2[m
Merge: 5aeb1aca daa6732c
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 31 09:52:13 2022 -0500

    Merge pull request #438 from Velociraptor85/patch-1
    
    fix background-scan link

[33mcommit 5aeb1aca1379a0295707f94d1800b545ef652fd5[m
Merge: ac57089b c680c47d
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 31 09:48:27 2022 -0500

    Merge pull request #460 from JimBugwadia/update_troubleshooting
    
    Update troubleshooting

[33mcommit ac57089bd483daef4318a44f5296df2caaeba0c0[m
Merge: cc8f8fed 597488c5
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 31 09:46:47 2022 -0500

    Merge pull request #461 from oshi36/auto-gen-url-fix
    
    fixed auto-gen URL

[33mcommit 597488c53f531928cf99ca296708c51da09e1273[m
Author: Oshi Gupta <oshiagupta36@gmail.com>
Date:   Mon Jan 31 13:33:50 2022 +0530

    fixed auto-gen url in verify images under writing policies
    
    Signed-off-by: Oshi Gupta <oshiagupta36@gmail.com>

[33mcommit c680c47d0b22c9a834ea86a743522429129d063d[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jan 30 11:06:37 2022 -0800

    add namespace
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 4fa6c83f6306b06b9e379f681ad6893de2854706[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jan 30 11:06:21 2022 -0800

    recovery for API server timeouts
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit cc8f8fed0559221c80b067847e74dccd22def085[m
Merge: f7c19b0c bc3fd716
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jan 29 14:43:17 2022 -0500

    Merge pull request #459 from onweru/main
    
    Enable New PolicyType Filter

[33mcommit bc3fd7169943edde31de9191d76d7ca5d33ccece[m
Author: weru <fromweru@gmail.com>
Date:   Sat Jan 29 22:14:56 2022 +0300

    update policy page
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit d604d65cf7ee1dbdeb3bf7c718082a3ef7daab09[m
Author: weru <fromweru@gmail.com>
Date:   Sat Jan 29 22:14:39 2022 +0300

    add policy filter
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit dfc55e04dddcf7543fb3d4cd68c41440f98c90da[m
Author: weru <fromweru@gmail.com>
Date:   Sat Jan 29 22:13:44 2022 +0300

    update go render template
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 738503fd2da4b41fd9a1876159145b7c571011dd[m
Merge: d75ac107 f7c19b0c
Author: weru <16350351+onweru@users.noreply.github.com>
Date:   Sat Jan 29 20:43:53 2022 +0300

    Merge pull request #1 from kyverno/main
    
    Update

[33mcommit a512b90e0ebdd1e939b0422c06ec060489696177[m
Author: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>
Date:   Thu Jan 27 18:35:52 2022 +0530

    validationFailureActionOverrides documentation
    
    Signed-off-by: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>

[33mcommit f7c19b0c3df9a5f9119b7e76855cc3429864e0be[m
Merge: c93af701 437dd0c0
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jan 16 21:39:46 2022 -0800

    Merge pull request #445 from JimBugwadia/clarify_mutual_auth
    
    fix typo and clarify webhook mutual auth

[33mcommit 437dd0c0be48f2495d04f4ca961e5749ef9e588a[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jan 16 21:19:43 2022 -0800

    fix spacing
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit f5fd06375df02396dbceca5fd02fe13bf30ec0b8[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jan 16 21:08:05 2022 -0800

    fix typo and clarify webhook mutual auth
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit c93af701af5b8be35860f61e23e8280c59ec0259[m
Merge: 92ccb4f8 416bf59e
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jan 16 20:19:13 2022 -0800

    Merge pull request #444 from JimBugwadia/threat_model
    
    add threat model details

[33mcommit 416bf59e398e02acb957135776ca9801382272be[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jan 16 09:36:06 2022 -0800

    fix text for mitigation-id-6
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 65b933ac485751a9018de4666660569e0658ccd2[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Jan 15 20:57:19 2022 -0800

    add thread model details
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 92ccb4f862b39dc9e9d3177cbff1e2ade408f11a[m
Merge: 81ab72d0 1e321475
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jan 15 19:16:16 2022 -0500

    Merge pull request #443 from JimBugwadia/star_mobile
    
    reduce text to prevent wrap on small/mobile screens

[33mcommit 1e321475b0b7f811942128f50f5595a004184d77[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Jan 15 15:51:44 2022 -0800

    reduce text to prevent wrap on small/mobile screens
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 81ab72d07738141a72dc189c1d767f99639e777b[m
Merge: 6db4b14a c776b8d2
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jan 13 08:47:42 2022 -0500

    Merge pull request #425 from vyankyGH/wildcard_support_selector
    
    Doc update to wildcard support match label selector

[33mcommit 6db4b14ae6884bcbdceba20df907e00ed4230450[m
Merge: 4b8d58c4 06855f5a
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jan 13 08:42:16 2022 -0500

    Merge pull request #439 from kyverno/update_resources
    
    Add recent resources

[33mcommit 06855f5a2244b5c175db528f9f9886b393418c76[m
Author: ShutingZhao <shuting@nirmata.com>
Date:   Thu Jan 13 18:26:04 2022 +0800

    update resources
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit daa6732c60d76999904efb29bd8c21f15941ddad[m
Author: Velociraptor85 <Velociraptor85@users.noreply.github.com>
Date:   Wed Jan 12 09:52:53 2022 +0100

    fix background-scan link

[33mcommit 4b8d58c495c0feb7ab8c6575c977cf8822c2b169[m
Merge: f781d649 36cb081f
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 10 10:13:22 2022 -0500

    Merge pull request #435 from chipzoller/main
    
    Render policies; fixes

[33mcommit 36cb081f83ef1276e565fde01601c5e6b1c1ec5b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 10 09:05:59 2022 -0500

    comment
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 48b35d46cad62a6a09406987a4dc288003a30212[m
Merge: 7f3f8695 6be17981
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 10 08:48:23 2022 -0500

    Merge branch 'main' of https://github.com/chipzoller/kyvernowebsite into main

[33mcommit 7f3f86950f6f01753cd67c7b8580ec1d92634eb5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jan 10 08:48:11 2022 -0500

    render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 7ba80db79f02f8a40f1bcec7da9f10ffb8852a35[m
Author: Sambhav Kothari <sambhavs.email@gmail.com>
Date:   Sun Jan 9 17:21:25 2022 +0000

    Rename function to parse_json
    
    Signed-off-by: Sambhav Kothari <sambhavs.email@gmail.com>

[33mcommit 98871e09287ee310112cc5f0aa38a243fb12d9c1[m
Author: Sambhav Kothari <sambhavs.email@gmail.com>
Date:   Sat Jan 8 19:50:14 2022 +0000

    Add `to_json` to the list of custom JMESPath functions
    
    Signed-off-by: Sambhav Kothari <sambhavs.email@gmail.com>

[33mcommit f781d649470e991a91f70a8b593adece99b92155[m
Merge: 033ed0bc 661db6b7
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Jan 5 08:19:23 2022 -0800

    Merge pull request #432 from kyverno/fix_installation_link
    
    Update link for direct install

[33mcommit 661db6b77bb246e119a76310d0ba998074c2c930[m
Author: ShutingZhao <shuting@nirmata.com>
Date:   Wed Jan 5 23:46:28 2022 +0800

    update link for direct install
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit 6be179812d19264b8561d65705762b652eeec7bc[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jan 1 08:09:16 2022 -0500

    fix mutate foreach
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 033ed0bc2995f8f58b5e47050076c79c9e149772[m
Merge: 7a132ab7 ecb55e8b
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 30 14:53:46 2021 -0500

    Merge pull request #427 from Anita-ihuman/main
    
    Create Release Management  guide

[33mcommit ecb55e8b2d0100de74682af58006deab326c11f3[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Dec 30 20:27:39 2021 +0100

    updating review
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit e170e8bc0e4fb874d423e747b9690e47757ab083[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Dec 30 19:56:13 2021 +0100

    updating review
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 21e8c3b4b6d686436e895c3fcb1c131f0d6b773f[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Dec 30 18:28:58 2021 +0100

    updating review
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 411a8324949b32110ac439ab4b340438857bb049[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Dec 30 18:16:11 2021 +0100

    Fixed reviewed changes
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 2ccc3ea092ddb11222c38005b6794254f3a1c611[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Dec 30 16:52:11 2021 +0100

    Fixed reviewed changes
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 527dc94251fbbfde788be3319510bafc1a33afbf[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Dec 30 16:17:11 2021 +0100

    updating review
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 372146191dfff9d67aa9e8580c06f20e657d3dfc[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Dec 30 16:11:27 2021 +0100

    updating review
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit e8c79b79dd29903cba20ae6daa595bb5be2e3903[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 29 17:36:07 2021 -0500

    add section on how report results are scored
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 84ed436fb133d27c40f9d1f1c7f901e519a61780[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 29 16:35:48 2021 -0500

    clarify allowable vars in background mode
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 190f3f48c5f0dbae206cd20610a2b0c2d5a64479[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 29 16:28:42 2021 -0500

    linting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ada0428152d964f3d3b40ec50a5351abd691f55c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 29 16:24:17 2021 -0500

    test
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ab9552e5737d14364eccc4f06047d6c102e9112e[m
Author: Danny Kulchinsky <dkulchinsky@fastly.com>
Date:   Tue Dec 21 12:02:58 2021 -0500

    document custom JMESPath truncate function
    
    Signed-off-by: Danny Kulchinsky <dkulchinsky@fastly.com>

[33mcommit 2860c06d93bfedc3c548138adbb7be894caff007[m
Author: ShutingZhao <shuting@nirmata.com>
Date:   Tue Dec 21 14:07:55 2021 +0800

    add versioning section
    
    Signed-off-by: ShutingZhao <shuting@nirmata.com>

[33mcommit c776b8d265d84d96fc47698fe684394265c6493b[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Tue Dec 21 11:00:46 2021 +0530

    add missing paths

[33mcommit c5a7c7f955cd88475671901c7ba3edcbd27bc65a[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Mon Dec 20 19:05:17 2021 +0530

    fix comment

[33mcommit cfa5f7c04900c1c5cb6dd4592cfb13ea4d567af4[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Fri Dec 17 15:21:41 2021 +0530

    fix comment

[33mcommit 324472a14f97103073b7ffc696f743aef2057731[m
Merge: 3cf7ca05 d7461fa8
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Fri Dec 17 10:48:08 2021 +0100

    Merge branch 'main' of https://github.com/Anita-ihuman/website into main

[33mcommit 3cf7ca05049248758cb6e714a9e66a46f78e20e1[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Fri Dec 17 10:47:48 2021 +0100

    updated changes
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit af0b60ed730b58e26e06929e233501d7b17cb522[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Fri Dec 17 11:22:36 2021 +0530

    fix text

[33mcommit d7461fa8b57f069d629ca780341a7a4a82cffa79[m
Merge: 51fc7c48 7a132ab7
Author: Anita-ihuman <62384659+Anita-ihuman@users.noreply.github.com>
Date:   Thu Dec 16 13:36:36 2021 +0100

    Merge branch 'kyverno:main' into main

[33mcommit 51fc7c4841506e9b0e15828c9640ccaecc51f0c1[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Dec 16 13:34:52 2021 +0100

    created a relase managemnet guide
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 89e5ba48945e00fa6fdd67e4e019a026da932b4b[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Thu Dec 16 14:26:48 2021 +0530

    doc update to wildcard support match label selector

[33mcommit 7a132ab7a7ff76f5a2ab7172a43364ad89d8c56c[m
Merge: 78d9395d 83fd2284
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Dec 14 08:01:00 2021 -0500

    Merge pull request #421 from chipzoller/main
    
    redner policies

[33mcommit 83fd2284ac2959674739b8d46e496b03d3270398[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Dec 14 07:58:34 2021 -0500

    redner policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 78d9395d296bf028b6c52637963edddeed5852ea[m
Merge: bbc10f7c e8bca18b
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Dec 13 16:17:15 2021 -0800

    Merge pull request #419 from JimBugwadia/governance_edits
    
    minor corrections and edits

[33mcommit e8bca18b6ea73f251af72169e211b9f2d3110852[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Dec 13 15:50:34 2021 -0800

    minor corrections and edits
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit bbc10f7c47f23758bc0633c61ce89eb4728dd6fc[m
Merge: 33af1040 e49ccf92
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Dec 13 15:11:01 2021 -0800

    Merge pull request #399 from Anita-ihuman/main
    
    Project governance doc update

[33mcommit e49ccf920ce0da9e8c7012ce7f420fca65f67ad6[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Mon Dec 13 20:48:02 2021 +0100

    mapped roles to fit github roles
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 4da7a5ca54a74c263eb8212a23d886696883245d[m
Author: Abhinav Sinha <zeborg3@gmail.com>
Date:   Sat Dec 11 01:46:10 2021 +0530

    Updated docs for `kyverno test` command with git path
    
    Signed-off-by: Abhinav Sinha <zeborg3@gmail.com>

[33mcommit 240e302ff2ea27d20692d503d93aa28139cba158[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Fri Dec 10 05:03:02 2021 +0100

    Fixed reviewed changes
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 33af10402cfb6c5438bd61be66d8d3f238e1e8e2[m
Merge: 7c4e78e1 9d04c2ae
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Dec 9 15:18:01 2021 -0800

    Merge pull request #415 from chipzoller/main
    
    Doc fixes

[33mcommit 9d04c2ae14da64f4fa0a426632029014de3e0c39[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 9 10:17:34 2021 -0500

    add entry to release notes for 1.5.2 from rc5
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 51e2a58e2d95a1b31fb640d4b2d5eec67e59b432[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 9 09:35:44 2021 -0500

    minor foreach policy tweak
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit d20dec78831723dd65ef04887c266e08603b5333[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 9 09:05:14 2021 -0500

    update refs so only request.namespace is there; add note in vars file
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 8f97826e74ea879704c6b17d14673b35b15da0ba[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 9 08:17:30 2021 -0500

    fix operator in example
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5b3348835b070750cae781fc44a70572ed2b439f[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 9 08:17:18 2021 -0500

    update matrix
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 7c4e78e14b606fff356c15fe7334cf84ff3728ab[m
Author: Shubham Palriwala <spalriwalau@gmail.com>
Date:   Thu Dec 9 18:38:40 2021 +0530

    [1.6.0] Security Section (#400)
    
    * init: security section
    
    Signed-off-by: ShubhamPalriwala <spalriwalau@gmail.com>
    
    * update security section
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * fix: rbac shell command & remove: redundant cosign and sbom in installation
    
    Signed-off-by: ShubhamPalriwala <spalriwalau@gmail.com>
    
    * remove kyverno:mutate role
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    * address comments
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>
    
    Co-authored-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit ad1445af755b81e5686cd6d0bd539ae3783dc518[m
Merge: b418b86a 8e9ea7f8
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Dec 8 13:50:24 2021 -0800

    Merge pull request #411 from chipzoller/main
    
    Updates for v1.5.2

[33mcommit 8e9ea7f8586daa47cd9c1f8abebe6a19e161424e[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 8 16:38:31 2021 -0500

    add 1.5.2 release notes
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 1dd70014c34105ee07fc03ea1ffa5283863ea132[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 8 16:12:29 2021 -0500

    render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 3f47facb81e3a2b64770bbfdc54440ff9711d9c3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 8 09:23:34 2021 -0500

    Update conditional examples from overlay -> patchStrategicMerge
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit d6fb924885eaa59e581d7238603d148933ce88b5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 8 09:23:12 2021 -0500

    Update .gitignore with latest Hugo lock file
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit fb6efc85e4de27e00c20f4ec2ec4ee31efd91d8e[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 8 08:21:03 2021 -0500

    fix mutate foreach example
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b418b86ad4fc27af4fc5294b54c8f205afba3327[m
Merge: 698e7f80 855df907
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Dec 7 07:55:02 2021 -0500

    Merge pull request #405 from chipzoller/main
    
    [1.5.2] extend escaping vars

[33mcommit 592400461bf0fd3d714a56e25bbe040d1f6c1a23[m
Merge: 312e0e45 ca25f293
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Mon Dec 6 18:33:03 2021 +0100

    implemeted the reviews
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 312e0e45d41545eddac377758074c2cebd674e2d[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Mon Dec 6 18:31:37 2021 +0100

    implements changes.
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 698e7f80eabec4f9f78a6dc773546a55a18e7a80[m
Merge: ebf43925 e5b8e4db
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Dec 6 08:02:17 2021 -0500

    Merge pull request #387 from nileshbhadana/patch-1
    
    Fixing query for failed rules

[33mcommit e5b8e4db0b610b00a2984e5780dd9da5577e1c30[m
Author: ɴɪʟᴇsʜ ʙʜᴀᴅᴀɴᴀ <nileshbhadana3@gmail.com>
Date:   Mon Nov 15 14:16:36 2021 +0530

    Fixing query for failed rules
    
    Fixing example query to get number for failed requests in 24 hours in default namespace.
    
    Signed-off-by: nileshbhadana <nileshbhadana3@gmail.com>

[33mcommit 855df90780a0514318df96b0f99b1de20b5701bd[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Dec 3 09:56:45 2021 -0500

    fix broken link
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f9b847283056e85b283e121519800086986a5e12[m
Merge: 16ac1cde 9d30f959
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Dec 3 09:55:44 2021 -0500

    Merge branch 'main' of https://github.com/chipzoller/kyvernowebsite into main

[33mcommit 16ac1cde484b0623595df0ab1540e31e81d47296[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 2 12:18:45 2021 -0500

    extend escaping vars
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ebf43925525aa264e176bb01ecc88726bba457cc[m
Merge: 0d68367e 8b6251af
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Dec 3 08:03:33 2021 -0500

    Merge pull request #317 from anushkamittal20/update-for-kyverno-flags
    
    [1.5.0] Updated doc for flags

[33mcommit 8b6251afe307bde8232da02941e4a726afcd160e[m
Author: anushkamittal20 <anumittal4641@gmail.com>
Date:   Fri Dec 3 15:45:24 2021 +0530

    changes for generateSuccessEvents
    
    Signed-off-by: anushkamittal20 <anumittal4641@gmail.com>

[33mcommit b8ee0d1d8003ade0e3a82e1415ddc305915398bf[m
Merge: 2cc7a379 0d68367e
Author: anushkamittal20 <anumittal4641@gmail.com>
Date:   Fri Dec 3 15:19:34 2021 +0530

    Merge branch 'main' of https://github.com/kyverno/website into HEAD

[33mcommit ee8b2010470e9f8f463d9e2e64f47bf08668dd65[m
Author: weiwei.danny <weiwei.danny@bytedance.com>
Date:   Fri Dec 3 17:47:02 2021 +0800

    document path_canonicalize custom JMESPath function
    
    Signed-off-by: weiwei.danny <weiwei.danny@bytedance.com>

[33mcommit ca25f293946912bbab52973836af21b4d25cc17c[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Fri Dec 3 09:09:08 2021 +0100

    updated the project roles
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 0d68367e13f73aedc16ef936ec970ba0485ec73c[m
Merge: c963ed66 d7333117
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 2 13:51:49 2021 -0500

    Merge pull request #406 from roeelandesman/main
    
    Fix grammar and spelling on Monitoring page

[33mcommit d73331176b699d0f099dc98b3807678e78a60824[m
Author: Roee Landesman <roee.landesman@sonos.com>
Date:   Thu Dec 2 10:31:37 2021 -0800

    Fix grammar and spelling on Monitoring page
    
    Signed-off-by: Roee Landesman <roee.landesman@sonos.com>

[33mcommit c963ed66a17c5b403673df5f3ac75370dba79b02[m
Merge: b7621d06 5ec837ac
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 2 12:21:51 2021 -0500

    Merge pull request #402 from kyverno/add-series-video
    
    Add the video of the Kyverno series - meet Kyverno maintainers

[33mcommit 9d30f9592cffb0eee922cf3b2d4a9d640439823a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 2 12:18:45 2021 -0500

    extend escaping vars
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b7621d066f22695b6449e723b8ffc46f08d4c87c[m
Merge: 74c5d82b 25aaf8ec
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 2 12:12:27 2021 -0500

    Merge pull request #351 from AverageMarcus/resource_quantities
    
    [1.5.2] Added docs for resource quantity comparison

[33mcommit 5ec837ac862a215380a457d3b1577f1fe45f32b4[m
Author: ShutingZhao <shutting06@gmail.com>
Date:   Fri Dec 3 01:10:49 2021 +0800

    add a new Interviews section
    
    Signed-off-by: ShutingZhao <shutting06@gmail.com>

[33mcommit 73157910fd86faa159a22bd5f0ac07a02136328a[m
Author: ShutingZhao <shutting06@gmail.com>
Date:   Wed Dec 1 23:50:40 2021 +0800

    Add the video of the Kyverno series - meet Kyverno maintainers
    
    Signed-off-by: ShutingZhao <shutting06@gmail.com>

[33mcommit e1c5288f6450da85e102b8c776ff8aaf41dff99d[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Wed Dec 1 00:41:24 2021 +0100

    added date to the release dates
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 6c73c10c3763ab32f78e3b13fca54347ff23786d[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Nov 30 23:32:44 2021 +0100

    implemeted the reviews
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 74c5d82bb0a16461e8b2788986a80c2659790638[m
Merge: b984b7a7 d10b0656
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Nov 29 09:16:18 2021 -0800

    Merge pull request #397 from blakyaks/main
    
    Add BlakYaks support entry

[33mcommit d10b065655c1962ef531c886c3a26f55a8203377[m
Author: Craig Hurt <craig.hurt@blakyaks.com>
Date:   Mon Nov 29 17:00:49 2021 +0000

    Updated services based on feedback.
    
    Signed-off-by: Craig Hurt <craig.hurt@blakyaks.com>

[33mcommit 66f95ff0ada43e90f3eaaae2936addc4b74f877f[m
Author: Craig Hurt <craig.hurt@blakyaks.com>
Date:   Mon Nov 29 16:38:30 2021 +0000

    Reworded BlakYaks service definition.
    
    Signed-off-by: Craig Hurt <craig.hurt@blakyaks.com>

[33mcommit 13771830fe0db943d7348b38b78e26d5abc483dc[m
Author: Craig Hurt <craig.hurt@blakyaks.com>
Date:   Mon Nov 29 15:34:39 2021 +0000

    Added services information for BlakYaks
    
    Signed-off-by: Craig Hurt <craig.hurt@blakyaks.com>

[33mcommit d82db4564feba225a2adae5761237426362020a6[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Mon Nov 29 11:14:08 2021 +0100

    removed the admin column
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 7662ed09be7c94090d3c942e819735386d628257[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Mon Nov 29 11:03:35 2021 +0100

    moved project governance to index.md
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit f044fa326732b0e0def9649f541ffc4865fdbeae[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Nov 25 19:35:57 2021 +0100

    format markdown
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 6ad9a796853e0de70fb05e16a4c3c1c584fff509[m
Author: Craig Hurt <craig.hurt@blakyaks.com>
Date:   Thu Nov 25 17:03:55 2021 +0000

    Added BlakYaks support entry
    
    Signed-off-by: Craig Hurt <craig.hurt@blakyaks.com>

[33mcommit 42b7b1efb3d64dded0781d74f16cf57002c51235[m
Author: Sebastian Widmer <sebastian.widmer@vshn.net>
Date:   Fri Nov 19 13:15:02 2021 +0100

    Document `pattern_match` JMESPath custom function
    
    Signed-off-by: Sebastian Widmer <sebastian.widmer@vshn.net>

[33mcommit b984b7a73c4526a6de0b66479a3359c27dc578f7[m
Merge: 1bf488f2 d6ca2be2
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Nov 12 22:44:04 2021 -0500

    Merge pull request #386 from Anita-ihuman/main
    
    Add a support page

[33mcommit d6ca2be2bacffb4f8c0422e775cbbd97f052beb1[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Sat Nov 13 04:42:01 2021 +0100

    spell checks
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit dfac1109d5c7235608687c07d6370e3a9393481d[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Nov 11 19:34:13 2021 +0100

    spell checks
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit cbf4f15a8ed2325dcc241f84e6ba7609b45bbd9d[m
Merge: 6297bb5c 6914031e
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Nov 11 19:09:43 2021 +0100

    Merge branch 'main' of https://github.com/Anita-ihuman/website into main

[33mcommit 6297bb5cdbef3c0df028f06aab51cc22af835d54[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Nov 11 19:09:18 2021 +0100

    fixed spell checks
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 6914031eebebcb2469ef3f0d2dc6b2f09ff301cd[m
Merge: 030737f0 1bf488f2
Author: Anita-ihuman <62384659+Anita-ihuman@users.noreply.github.com>
Date:   Thu Nov 11 18:37:51 2021 +0100

    Merge branch 'kyverno:main' into main

[33mcommit 030737f0ebf27420089ed60f7e936674ff4be3a8[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Nov 11 18:35:48 2021 +0100

    add a supports page page
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 1bf488f2f71d71603647b7e74cb53f59f0eabcef[m
Merge: d3a40b16 91903fb3
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Nov 9 08:52:48 2021 -0500

    Merge pull request #374 from NoSkillGirl/update_cli_doc_with_apply_result
    
    [1.5.0] Updated CLI doc for `apply` command result

[33mcommit 91903fb3dfe1cee495eccc58b000e93a99ddf5ed[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Mon Nov 8 11:01:28 2021 +0530

    fixing Markdown linting
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit d3a40b16b405bf3f93573ab29b5023e37692c3cf[m
Merge: 410db452 8b36f568
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 3 12:16:43 2021 -0400

    Merge pull request #373 from chipzoller/main
    
    update mutate foreach example; minor linting; render policies

[33mcommit 8b36f568efa62fc1707129e5eb2322debd29830a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 3 12:05:06 2021 -0400

    render new policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6efc37baf040f8f30733080283dd741b0de0f79e[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Tue Nov 2 21:01:31 2021 +0530

    updated cli doc
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 318ebb115e5ed2d0a63f6541e7999c2d65ca0077[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Nov 2 08:31:22 2021 -0400

    update mutate foreach example; minor linting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 410db452f44012a1a7c76d890257965f495276e8[m
Merge: b393e5b8 2871d9da
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Nov 1 12:44:00 2021 -0700

    Merge pull request #368 from chipzoller/main
    
    Doc updates

[33mcommit b393e5b865575658b5ca576b05f06b6b5eea5139[m
Merge: dfa56ebb a838a90e
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Nov 1 12:42:53 2021 -0700

    Merge pull request #361 from Anita-ihuman/main
    
    Added call to participate button in Kyverno Certification

[33mcommit 25aaf8ecbbdc96241bdcbf85c9e31ee678200428[m
Author: Marcus Noble <github@marcusnoble.co.uk>
Date:   Mon Nov 1 06:42:11 2021 +0000

    Use markdown links
    
    Signed-off-by: Marcus Noble <github@marcusnoble.co.uk>

[33mcommit 2871d9dae740e94867e44bc19ce21cc7fa4ec7ea[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Oct 31 12:18:11 2021 -0400

    adds 1.5.0 and 1.5.1 release notes
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 514994930e09a6d8a78eeb925dba6d98503f194a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Oct 31 09:16:25 2021 -0400

    linting, spelling
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 571ac1c1dcf6287676066d4412f6d769b0af90f1[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Oct 31 08:48:28 2021 -0400

    Link validate.deny to preconditions for operators
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5ff857269569c8fae129b0a0c1bce1a5148a9be3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Oct 31 08:41:46 2021 -0400

    Latest resources
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 835be0be4b84286897fb0a56b0d608769a4bebe6[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Oct 31 08:30:26 2021 -0400

    linting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit c825cf547dbae1a8651a6b197b3a6d829af25cbb[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Oct 31 08:24:17 2021 -0400

    remove cert validity period; minor linting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit dfa56ebb559b3fed255007f9a733b1a77d346350[m
Merge: 88bbe8b4 5bb62696
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Oct 31 08:16:56 2021 -0400

    Merge pull request #356 from esantoro/main
    
    Fix website build using containers

[33mcommit 88bbe8b420d4058ebd230db0ce2352ad98b3ec39[m
Merge: d87d4d36 0c89e7d0
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Oct 31 07:41:12 2021 -0400

    Merge pull request #367 from mritunjaysharma394/update-1.5
    
    updates install kyverno steps from release manifest

[33mcommit 0c89e7d03ff9a22ec61d1eb7e00062b51013c8d3[m
Author: Mritunjay Sharma <mritunjaysharma394@gmail.com>
Date:   Sun Oct 31 16:37:25 2021 +0530

    updates install kyverno steps from release manifest
    
    Signed-off-by: Mritunjay Sharma <mritunjaysharma394@gmail.com>

[33mcommit a838a90e4ee5e26221abb4fa916713de37c7032d[m
Merge: 2d345fd1 5a06a7d4
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Sun Oct 31 09:05:07 2021 +0100

    Merge branch 'main' of https://github.com/Anita-ihuman/website into main

[33mcommit 2d345fd1cb77afa0785ab87490d1bb45f8964fbe[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Sun Oct 31 09:04:25 2021 +0100

    updated adopters header
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit e9f08cd85bc0337cd52d2ef3729821c02db93f52[m
Author: Łukasz Jakimczuk <lukasz.j@giantswarm.io>
Date:   Fri Oct 29 11:36:23 2021 +0200

    Adding info about negative range
    
    Signed-off-by: Łukasz Jakimczuk <lukasz.j@giantswarm.io>

[33mcommit 1e9055a9c0ffccaf9112d3a69d118d223779a9f4[m
Author: Łukasz Jakimczuk <lukasz.j@giantswarm.io>
Date:   Fri Oct 29 11:00:34 2021 +0200

    Listing Range operator
    
    Signed-off-by: Łukasz Jakimczuk <lukasz.j@giantswarm.io>

[33mcommit d87d4d36a187733b637907c10cb5d295db72d858[m
Merge: 334f8fe2 8baadd54
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Oct 28 21:19:13 2021 -0700

    Merge pull request #309 from ShubhamPalriwala/cosign-and-generate-sbom
    
    [Docs] Sign images and generate SBOM using cosign

[33mcommit 5a06a7d4891812d02e0d40a955059e55a087c99b[m
Merge: c2ed6e10 334f8fe2
Author: Anita-ihuman <62384659+Anita-ihuman@users.noreply.github.com>
Date:   Tue Oct 26 18:29:42 2021 +0100

    Merge branch 'kyverno:main' into main

[33mcommit c2ed6e10b3e82e92a6533423d40adcee66bf7735[m
Merge: e23b300d 8ee84b7e
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Oct 26 18:27:42 2021 +0100

    Merge branch 'main' of https://github.com/Anita-ihuman/website into main

[33mcommit e23b300dafd51d0ce01981b10598c3bb3dad1656[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Oct 26 18:25:03 2021 +0100

    call to participate in adopters program
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 2cc7a379d4f51a298b1327191854b5eeb1cac04a[m
Merge: d4299bb5 334f8fe2
Author: anushkamittal20 <anumittal4641@gmail.com>
Date:   Tue Oct 26 20:10:10 2021 +0530

    resolved merge conflicts
    
    Signed-off-by: anushkamittal20 <anumittal4641@gmail.com>

[33mcommit d4299bb591308fe5a8e254a766fcd3b10257dca2[m
Author: anushkamittal20 <anumittal4641@gmail.com>
Date:   Tue Oct 26 20:04:54 2021 +0530

    Fixes in the flags list
    
    Signed-off-by: anushkamittal20 <anumittal4641@gmail.com>

[33mcommit 8baadd54dfa5407cc8d0c7ea9279b3b915880848[m
Merge: 80ef6d0a 334f8fe2
Author: ShubhamPalriwala <spalriwalau@gmail.com>
Date:   Tue Oct 26 11:50:43 2021 +0530

    Merge branch 'main' of https://github.com/ShubhamPalriwala/website into cosign-and-generate-sbom
    
    Signed-off-by: ShubhamPalriwala <spalriwalau@gmail.com>

[33mcommit 80ef6d0a08abce784bf134fd17ec52535098e78b[m
Author: ShubhamPalriwala <spalriwalau@gmail.com>
Date:   Tue Oct 26 11:45:52 2021 +0530

    feat: docs for cosign
    
    Signed-off-by: ShubhamPalriwala <spalriwalau@gmail.com>

[33mcommit 334f8fe2d83298b75a54b863054c91f1247568e9[m
Merge: f34b461f 342174a0
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 25 18:35:52 2021 -0700

    Merge pull request #355 from developer-guy/patch-1
    
    Update verify_images.md with the new flag standard for cosign

[33mcommit f34b461f9de8909b75782dc7e519958530fe41be[m
Merge: d87a6a3e f099bd4d
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Oct 25 20:28:18 2021 -0400

    Merge pull request #358 from chipzoller/main
    
    create policy-settings file and address comments

[33mcommit f099bd4daa95b8375568ed2dbd11615c9cfa9a25[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Oct 25 20:21:22 2021 -0400

    create policy-settings file and address comments
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit d87a6a3e41b59f41a2cf5680ce012ff8468ee96e[m
Merge: 293ea5a5 e5b04218
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Oct 25 20:09:12 2021 -0400

    Merge pull request #339 from chipzoller/main
    
    [1.5.0] Doc updates

[33mcommit e5b04218be29a9973516d20dacd1ce5734a169f8[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Oct 25 20:06:16 2021 -0400

    Push fixes; re-render policies to catch 3 new ones.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5bb62696acc2a9355239873912b84e7de26d430d[m
Author: Emanuele Santoro <emanuele.santoro@facile.it>
Date:   Mon Oct 25 21:24:56 2021 +0200

    Makefile: fix permissions for target container-serve
    
    Signed-off-by: Emanuele Santoro <emanuele.santoro@facile.it>

[33mcommit bfa2985e01f159346a0c7e1a37a8a3034a655fc0[m
Author: Emanuele Santoro <emanuele.santoro@facile.it>
Date:   Mon Oct 25 18:59:15 2021 +0200

    Makefile: add missing comments for container-* targets
    
    Signed-off-by: Emanuele Santoro <emanuele.santoro@facile.it>

[33mcommit 1c56874f08825e067b6c4e335bb36165d2673278[m
Author: Emanuele Santoro <emanuele.santoro@facile.it>
Date:   Mon Oct 25 18:57:24 2021 +0200

    fix dockerfile for container image creation
    
    Signed-off-by: Emanuele Santoro <emanuele.santoro@facile.it>

[33mcommit 2dfed087f030eb23f656631ce95d5a5552dde8c8[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Oct 25 12:38:43 2021 -0400

    re-render policies with updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ccd50e4a260b225b902f3296f2971621f5238640[m
Merge: b350b1ae 293ea5a5
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Oct 25 12:23:27 2021 -0400

    Merge branch 'main' into main

[33mcommit b350b1ae72ba94ae071b0a1a50f961c0e0b32430[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Oct 25 12:15:18 2021 -0400

    update ConfigMap Flags based on upstream main
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 342174a0d537e130f41f12e6d4198e6ee377dc39[m
Author: Batuhan Apaydın <developerguyn@gmail.com>
Date:   Mon Oct 25 13:46:53 2021 +0300

    Update verify_images.md with the new flag standard for cosign
    
    Signed-off-by: Batuhan Apaydın <batuhan.apaydin@trendyol.com>

[33mcommit fe3d1723e9cd051e13a8707d16d22dc7dddf5932[m
Author: anushkamittal20 <anumittal4641@gmail.com>
Date:   Sat Oct 23 15:55:06 2021 +0530

    Added doc for new operators
    
    Signed-off-by: anushkamittal20 <anumittal4641@gmail.com>

[33mcommit 293ea5a5c36277278f56ee6dd21c90e01a090049[m
Merge: 329e3e3d 679221f0
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Oct 22 10:21:42 2021 -0700

    Merge pull request #350 from JimBugwadia/policy-settings
    
    update policy settings and webhook docs

[33mcommit 810fe2643b55e38eb48e4fa65147aac0d38fe74b[m
Author: Marcus Noble <github@marcusnoble.co.uk>
Date:   Fri Oct 22 08:29:11 2021 +0100

    Added docs for resource quantity comparison
    
    Signed-off-by: Marcus Noble <github@marcusnoble.co.uk>

[33mcommit 679221f00a03fe7bbe05726ed87571cf2c8af9b0[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Oct 21 23:57:48 2021 -0700

    update policy settings and webhook docs
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 329e3e3d189175f7a016cf8396049cb5fff9035b[m
Merge: 029631a5 e9927e27
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Oct 21 17:57:21 2021 -0700

    Merge pull request #347 from kyverno/render_nginx_custom_snippets
    
    render policies

[33mcommit e9927e27fcfc8f810c2061137ad993c1f4d51271[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Oct 21 16:13:44 2021 -0700

    render policies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 029631a58182ec72390b1e7d8765ffff0d64583c[m
Merge: 8ee84b7e 8baed317
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 20 12:52:52 2021 -0700

    Merge pull request #343 from JimBugwadia/main
    
    update versions for main (add v1.5.0)

[33mcommit 8baed31706d1dd9b7f07c00fc26ade58c3406768[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 20 12:40:51 2021 -0700

    update versions for main
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit e6a2b524cb1c15c76fc56834552dc4506b5a39fa[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 20 12:40:05 2021 -0700

    update versions for main
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 5b31dc1911e23bf4f2b1fd599574be646559b98f[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 20 12:35:52 2021 -0700

    update versions for 1.5.0
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 8ee84b7ec600bf0d9d8052f1117c83ce18ec26c8[m
Merge: 4f790e08 4d6d718a
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 18 22:59:36 2021 -0700

    Merge pull request #341 from JimBugwadia/foreach-list
    
    update foreach docs for lists

[33mcommit 4d6d718a6fb32809ac3cba19389b78f1aa0a0c22[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 18 22:59:18 2021 -0700

    fix typos
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 4f790e087c469b29ad5afa45c8eff7bd2d369e9b[m
Merge: 44041f7f 7ebdab06
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 18 22:54:37 2021 -0700

    Merge pull request #316 from kyverno/dynamic_webhooks
    
    [1.5.0] Update docs for dynamic webhooks

[33mcommit f753cfa154180880d1cf29574675785f9eaa0d5d[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 18 17:56:48 2021 -0700

    update foreach docs for lists
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 6e8cbf1e554afd6b1608eb3f6b75d910afafebb9[m
Author: anushkamittal20 <anumittal4641@gmail.com>
Date:   Mon Oct 18 22:06:51 2021 +0530

    Divided the flags list
    
    Signed-off-by: anushkamittal20 <anumittal4641@gmail.com>

[33mcommit 6743a52b0043ed47e32e59a9d6eace5741ac7882[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 10:33:00 2021 -0400

    HA linting and typos.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 23b3de3d3142c3c8b683627d7c74c5897ad852fb[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 10:12:16 2021 -0400

    Add a note on test command that it supports auto-gen.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 3e13d8fe66b82a3c89fd9f5c7c171fd728345301[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 09:57:53 2021 -0400

    add --webhookTimeout flag
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 819ede18f855397698b35fcf83f240d97dc56ac9[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 09:55:17 2021 -0400

    Add troubleshooting on identifying excluded resources
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 989974505a3c71302d7934d9cd3ac3d0a0cfcdb0[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 09:54:53 2021 -0400

    Update name of ConfigMap flag to resourceFilters.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b483f4ee6a93813dbd0d407f95310124df64aa48[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 09:41:21 2021 -0400

    verify-images linting and typos
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 25fe3d39a1d9716512ac44e61937bafb44079be7[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 09:32:38 2021 -0400

    Add section on escaping variables.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit d183126e6ee96d9914de550fa2864a8da710e192[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 09:02:05 2021 -0400

    Add paragraph on wildcard in kinds during match-exclude.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5850ccb1deecf4b85c26384323724e3e522b01f4[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 08:49:55 2021 -0400

    forEach linting and clean-up
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit d864649d7c0e77c037c6e8728c41f20c118e970c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 08:42:39 2021 -0400

    Replace anyPattern example with less misleading one from samples repo.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 96c0bf2c2d37cbe99222a330744adc278ca124a6[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 08:17:39 2021 -0400

    Create a flags section for containers, move background-scan.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 66b8f7893755afd65a4de271655f7ebfa44d7130[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Oct 16 08:11:07 2021 -0400

    Address internal logic on preexisting resource violations.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 79a741c76e94401456729b634c0e237b07b30719[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 17:14:33 2021 -0400

    Remove mention of custom JMESPath function contains
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 59392c59e3342fe44da2abe882d114022c7fd496[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 17:11:50 2021 -0400

    Add a tip about schemaValidation field.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 869ce77a474b5f7931ce86528fc6f4054d646101[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 16:57:04 2021 -0400

    Add docs on global anchor.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f128a1f604284bbcd378b5f8fd68b9fcf2eed0ff[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 16:13:36 2021 -0400

    Remove overlay docs; minor fixes to forEach.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 8083b9b631afd48fb5d86e4372703bc667cf8a46[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 16:07:41 2021 -0400

    Update CLI test file schema.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b0e6ee444cd2639ae41f033bc4efd1aa5c2b70b9[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 15:36:17 2021 -0400

    Clarify vars may be used in any apiCall field.
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 44041f7fd1469ed3765bcadaee87f2ccc9c29d59[m
Merge: cc95e555 73a97c25
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 15:17:56 2021 -0400

    Merge pull request #334 from AverageMarcus/base64
    
    [1.5.0] add base64 functions to custom function docs

[33mcommit cc95e5553f0051a123b3edf0849653f1af7d4616[m
Merge: 05807f0e fed89422
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 15:14:06 2021 -0400

    Merge pull request #307 from ojhaarjun1/jmespath-arithmetic
    
    [1.5.0] JMESPath Arithmetic Operators

[33mcommit 05807f0e31097997f7ce268e3d9a3383b84a4e8f[m
Merge: 5407ce10 d52dad61
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 15:13:52 2021 -0400

    Merge pull request #304 from treydock/helm-policies
    
    [1.5.0] Update install/update/uninstall steps for Helm chart changes

[33mcommit 5407ce10e07ed2a6b9aba995ffc031921ea07f66[m
Merge: d595003f bc4016fc
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 15:13:18 2021 -0400

    Merge pull request #300 from ojhaarjun1/cli-global-vars
    
    [1.5.0] Adding documentation for CLI Global Variables

[33mcommit d595003f6c1edb597056128647345cd1a9235d05[m
Merge: a18ec5b2 d17d6a37
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 15:12:50 2021 -0400

    Merge pull request #295 from yashvardhan-kukreja/issue-294/sync-docs-metrics-related-changes
    
    [1.4.3] update docs to comply with latest metrics-related changes

[33mcommit a18ec5b265e580a79c178c8f510503b819235692[m
Merge: e89881e5 38cf6296
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 14:57:58 2021 -0400

    Merge pull request #338 from kyverno/update_install
    
    [1.5.0] Update install guidance

[33mcommit 38cf6296415eff406b89b8155acf4a570b724403[m
Author: ShutingZhao <shutting06@gmail.com>
Date:   Fri Oct 15 11:15:04 2021 -0700

    update install guidance
    
    Signed-off-by: ShutingZhao <shutting06@gmail.com>

[33mcommit e89881e5d468705625154dbd0825a7089cd900fc[m
Merge: e128c1d4 b5468d5f
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 10:51:43 2021 -0400

    Merge pull request #310 from chipzoller/main
    
    CLI updates; policy rendering

[33mcommit b5468d5fa051c798538fc2f28722a74141db674a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 15 09:52:46 2021 -0400

    policy renders
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit e128c1d4f7edc367756af5e43a91c0eece7775e1[m
Merge: e1b29807 b6845f74
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Oct 14 14:21:09 2021 -0400

    Merge pull request #291 from Anita-ihuman/main
    
    Created a release note for the From v1.4.0- 1.0.0

[33mcommit b6845f7402064ceb6af3afe5f8604cf3c3a9f5d0[m
Merge: 665b167c e1b29807
Author: Anita-ihuman <62384659+Anita-ihuman@users.noreply.github.com>
Date:   Thu Oct 14 15:03:43 2021 +0100

    Merge branch 'main' into main

[33mcommit 665b167c72740eec0854fc666692e40a381c1cdd[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Oct 14 14:59:16 2021 +0100

    changed release note weight
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 7ebdab065c9281acfdd747842033aa94fc0c1ac5[m
Author: ShutingZhao <shutting06@gmail.com>
Date:   Wed Oct 13 23:15:36 2021 -0700

    remove duplicate parenthesis
    
    Signed-off-by: ShutingZhao <shutting06@gmail.com>

[33mcommit 73a97c257aab89c0aeec0e60b46f3a7db115248c[m
Author: Marcus Noble <github@marcusnoble.co.uk>
Date:   Thu Oct 14 07:04:05 2021 +0100

    add base64 functions to custom function docs
    
    Signed-off-by: Marcus Noble <github@marcusnoble.co.uk>

[33mcommit e1b2980737dd431542794e9c2f6e5776c8be3d2e[m
Merge: f5029f8c dc7d7195
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Oct 13 10:08:38 2021 -0400

    Merge pull request #315 from NoSkillGirl/update_generate_doc_2155
    
    Note about generating custom resources

[33mcommit dc7d7195a631f56057b98be6f32c487f5570fe23[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Tue Oct 12 13:05:46 2021 +0530

    updated note
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 420be39650349ebacf81de42b970a04521f5247b[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Oct 12 01:29:58 2021 +0100

    changed release not weight
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit f5029f8c991080384a1b95ec082073930f012a8c[m
Merge: f270c191 92f07cf3
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 11 16:22:22 2021 -0700

    Merge pull request #328 from JimBugwadia/main
    
    add 1.4.3 in main

[33mcommit 92f07cf30fe75fb5d89c198edea410db6ad780ba[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 11 16:12:59 2021 -0700

    fix config.toml
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 40cb56a7da8683b68545eb3a41da15efb69f7d22[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 11 15:07:01 2021 -0700

    empty change to trigger deploy
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 7cc52127abd27951e7f144542fbd4bb1ce804297[m
Merge: 73a7da7d f270c191
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 11 09:08:37 2021 -0700

    Merge branch 'kyverno:main' into main

[33mcommit 73a7da7defb39089e86176426cfa1c95bd1d1ddb[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 11 09:04:55 2021 -0700

    add v1.4.3
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit f270c191f79ee326fd209e775d524e704bfb459a[m
Merge: 21698df0 3b3eb788
Author: shuting <shutting06@gmail.com>
Date:   Mon Oct 11 09:01:54 2021 -0700

    Merge pull request #324 from JimBugwadia/main

[33mcommit 3b3eb788b0ea59fb191b00692f40fad00c557ec8[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Oct 10 23:03:17 2021 -0700

    update versions for main
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 21698df0d7a43d91ed228b90d5235a9d862d3334[m
Merge: 96d039ea 22eec600
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Oct 9 15:17:18 2021 -0700

    Merge pull request #319 from JimBugwadia/docs/foreach
    
    add foreach docs

[33mcommit 22eec600a73a2b3f6fd54361819b3d354dc3d815[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Oct 9 15:11:36 2021 -0700

    add `-` to patch and remove DELETE reference in mutate docs
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 96d039eaac1a4d3fa9a06270eb8bdb0fd2da26a7[m
Merge: 5cbabee9 592edc22
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Oct 9 12:40:45 2021 -0700

    Merge pull request #320 from JimBugwadia/docs/cosign_attest
    
    docs for attestations

[33mcommit 5d8309eaf789ce2511f090fe949589179b304a40[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Oct 9 12:36:57 2021 -0700

    resolve comments
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 0ea73b5a3573f5a5bd17547324775153ae573a8c[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Oct 9 12:10:10 2021 -0700

    replace `fetch` for list
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 592edc221ebd9be23bf93d970b2cc5f5133d2679[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Oct 8 19:45:54 2021 -0700

    docs for attestations
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 9cfcfd5d014950a97830e7864db7e5032dd2d9c4[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Oct 8 18:16:56 2021 -0700

    fix typo in releases
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 4677a2069020788d9200ac89bee8b51104643d6c[m
Merge: f36e05bb 34c779c4
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Sat Oct 9 01:57:16 2021 +0100

    Merge branch 'main' of https://github.com/Anita-ihuman/website into HA-key-components

[33mcommit f36e05bb0e0617fcc4f5cfe011ef93d51ff5c268[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Sat Oct 9 01:56:23 2021 +0100

    fixing indentation and typos
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 042350aab5f272783165539b36b4f8ad26b367f6[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Oct 8 12:36:09 2021 -0700

    add foreach docs
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 2183c70bb0644770863655bcdf42ab13c146c350[m
Author: ShutingZhao <shutting06@gmail.com>
Date:   Thu Oct 7 12:16:08 2021 -0700

    update manual configure webhooks instruction
    
    Signed-off-by: ShutingZhao <shutting06@gmail.com>

[33mcommit 4741a323f40207451f970dbdc4f53f28893cb11d[m
Author: anushkamittal20 <anumittal4641@gmail.com>
Date:   Thu Oct 7 02:22:51 2021 +0530

    Minor fixes
    
    Signed-off-by: anushkamittal20 <anumittal4641@gmail.com>

[33mcommit 79ed45d4d40adb4970d317011066ccb4e4830182[m
Author: anushkamittal20 <anumittal4641@gmail.com>
Date:   Wed Oct 6 23:37:56 2021 +0530

    Adding the missing flags in documentation
    
    Signed-off-by: anushkamittal20 <anumittal4641@gmail.com>

[33mcommit d013aeafd837333de6b2e55fc0e74ac2c4a97986[m
Author: anushkamittal20 <anumittal4641@gmail.com>
Date:   Wed Oct 6 22:55:20 2021 +0530

    Updated doc for flags
    
    Signed-off-by: anushkamittal20 <anumittal4641@gmail.com>

[33mcommit 3f46cafe99c9ae5aaa7a0ae886c6627149ed2e8e[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Wed Oct 6 21:39:11 2021 +0530

    updated note
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit c8bad1d2eeba45d7a19dac95331078cfc224c845[m
Author: ShutingZhao <shutting06@gmail.com>
Date:   Wed Oct 6 00:29:10 2021 -0700

    updated to suggested description
    
    Signed-off-by: ShutingZhao <shutting06@gmail.com>

[33mcommit 9743bc38f7596a23af5fbc32b0ac09565b448477[m
Author: ShutingZhao <shutting06@gmail.com>
Date:   Tue Oct 5 23:28:03 2021 -0700

    add new label to the policy info metric
    
    Signed-off-by: ShutingZhao <shutting06@gmail.com>

[33mcommit cd9bdf89b5472daae6721ddb5501f70003fea9aa[m
Author: ShutingZhao <shutting06@gmail.com>
Date:   Tue Oct 5 23:11:29 2021 -0700

    update disabled secenario
    
    Signed-off-by: ShutingZhao <shutting06@gmail.com>

[33mcommit b35e879a0d905a4ee74c0eae6c4cd4e117374c6f[m
Author: ShutingZhao <shutting06@gmail.com>
Date:   Tue Oct 5 23:06:39 2021 -0700

    update docs for dynamic webhooks
    
    Signed-off-by: ShutingZhao <shutting06@gmail.com>

[33mcommit c0bf9aca52fbb3d4c137fc0e0cddfce3bb4be3dc[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Tue Oct 5 22:44:09 2021 +0530

    added a note
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit f94941e2f123d755f8df021d8093847846a9e5ed[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Oct 5 17:41:09 2021 +0100

    updated  the config file
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 34c779c4620a20794c8f6ef47f1ce9c38b2825a6[m
Merge: 1339126b 5cbabee9
Author: Anita-ihuman <62384659+Anita-ihuman@users.noreply.github.com>
Date:   Tue Oct 5 17:37:36 2021 +0100

    Merge branch 'kyverno:main' into main

[33mcommit 1339126b8d25ebc1859587299329133f99e64ff1[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Oct 5 17:34:26 2021 +0100

    updated  the contributing.md file
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit ee5b92046236562ac890cee228b773a37e6d05b0[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Oct 5 17:25:06 2021 +0100

    fixing spell error
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 704bc4fa9d8750f82443946dfc1c90510dfcf3f3[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Sep 30 09:22:59 2021 +0100

    updated  the contributing.md file
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 2386de819209b14a2480ba2338eb1372dea04c4f[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Sep 30 09:18:43 2021 +0100

    updated  the contributing.md file
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 5cbabee9ba0c92f426084f751f310220f41ab5bf[m
Merge: fe9ed774 661eeb67
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Sep 29 07:03:16 2021 -0700

    Merge pull request #311 from ampc/patch-1
    
    Update link to grafana dashboard

[33mcommit 661eeb67a4dc9b366008917e329e4b5dff5a68db[m
Author: Antonio Carvalho <antoniocarvalho800@gmail.com>
Date:   Wed Sep 29 10:27:14 2021 +0100

    Update link to grafana dashboard

[33mcommit 06237b87b770a82d63d3d7273cb40c5f495fe03a[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Wed Sep 29 01:37:24 2021 +0100

    refined the contributing.md file
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 79ac6adfe1e79f950421d2148a0c9ad569413766[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Wed Sep 29 00:16:45 2021 +0100

    Fixing typo in HA doc section
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 758093baac7d011083e8629b0eab5e6df350b982[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Sep 28 14:10:06 2021 +0100

    correcting the config file.
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit ec40dc692805a3cc038aab9efe89dcfd101cafc4[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Sep 27 16:24:07 2021 -0400

    pick up annotations
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6a4097021443734f3ea90ef95c0d5e08d9aef9c5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Sep 27 16:14:55 2021 -0400

    policy re-render
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6e9ac50230ecad619e88401a26eae6be5c934531[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Sep 27 13:38:07 2021 -0400

    policy updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit db51ecaa126a43d373b0b624a04296cb8d5cede1[m
Merge: 825bb7ff 38c1f1b4
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Sep 27 12:05:27 2021 -0400

    Merge branch 'main' of https://github.com/chipzoller/kyvernowebsite into main

[33mcommit 825bb7ffcdfa2569237dc2b434f5ff13f171c284[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Sep 1 10:19:48 2021 -0400

    add apply example
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bc4016fc4a657a4f2eb85304c4016615ad488c9c[m
Author: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>
Date:   Sat Sep 25 20:30:27 2021 +0530

    Minor indentation fix
    
    Signed-off-by: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>

[33mcommit fe9ed774ef1b7dfaa3b31a4b6fa9d44909fbcfa2[m
Merge: e2b3ecf8 cbbf7661
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Sep 25 10:45:40 2021 -0400

    Merge pull request #297 from vivek-yamsani/policy_report_changes
    
    updated the cmd in viewing policy report violations

[33mcommit 10e551f9f895d98e2fb97c3dfa681e8bcee30098[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Sat Sep 25 14:12:08 2021 +0100

    increase the weight of this file
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit ca12df2e9b152a7bb70daf6a46a17b0d1dfbba56[m
Merge: 1f3d710a 42cc6972
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Sat Sep 25 14:09:26 2021 +0100

    Merge branch 'main' of https://github.com/Anita-ihuman/website into HA-key-components

[33mcommit fed8942236813228f5fe34c6e9203072acfd81a7[m
Author: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>
Date:   Fri Sep 24 11:15:32 2021 +0530

    JMESPath Arithmetic Operators
    
    Signed-off-by: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>

[33mcommit d52dad61138deb5e87353b0b56280c15fd580875[m
Author: Trey Dockendorf <tdockendorf@osc.edu>
Date:   Wed Sep 22 15:44:23 2021 -0400

    Update install/update/uninstall steps for Helm chart changes
    
    Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>

[33mcommit 0160428b5e910c3678a3ad8311300496b4cefd65[m
Author: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>
Date:   Wed Sep 22 10:29:37 2021 +0530

    Indentation fix
    
    Signed-off-by: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>

[33mcommit 33452878e416fda1047fbca093698f1276e27d2c[m
Author: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>
Date:   Mon Sep 20 11:23:19 2021 +0530

    Adding documentation for CLI Global Variables
    
    Signed-off-by: Kumar Mallikarjuna <kumarmallikarjuna1@gmail.com>

[33mcommit 42cc6972e9e39546cfa09efee5375e6caf7556b3[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Fri Sep 17 22:09:56 2021 +0100

    fixed typo in config.yml
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 6de7f515b175f88bff6e2d2c8afbd296dac240b1[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Fri Sep 17 08:14:46 2021 +0100

    fixed typo in config.yml
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit cbbf7661c100367affe3c6c098029f8f2e2f60f6[m
Author: vivek <vivekyamsani@gmail.com>
Date:   Fri Sep 17 08:59:32 2021 +0530

    updated the cmd in viewing policy report violations
    
    Signed-off-by: vivek <vivekyamsani@gmail.com>

[33mcommit e26c5169c97da2842163c813dc23c605c2cfe297[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Thu Sep 16 11:35:08 2021 +0100

    adding contributor images
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit d17d6a372da4d36975415ec3403d6980dbac2939[m
Author: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>
Date:   Thu Sep 16 06:51:50 2021 +0530

    update docs to comply with latest metrics-related changes
    
    Signed-off-by: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>

[33mcommit 76d39250d5c5a06c786a38fcb86db80876ce4174[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Wed Sep 15 23:45:21 2021 +0100

    updating the release notes
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 1f3d710af9725731dc4eb8eaf4fca46fd4a97273[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Wed Sep 15 22:30:09 2021 +0100

    updating the HA section
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit b560d444709171e687a8fc0c6ff3ca694f087c7b[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Wed Sep 15 22:29:16 2021 +0100

    updating the HA section
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit e2b3ecf884c9d27339b382ce66ab8f6e786cb390[m
Merge: eb597f59 0c000739
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Wed Sep 15 14:49:09 2021 +0530

    Merge pull request #293 from NoSkillGirl/correct_policy_name
    
    correcting policy name in variable file | CLI

[33mcommit 0c0007392f94750f87ab34f562e3a2bfa7bf1997[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Wed Sep 15 14:35:04 2021 +0530

    corrected policy name
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit d4aaeab2c310efb30c6751ec21fc110d92260a8b[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Sep 14 21:31:12 2021 +0100

    updating the release notes
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 9ab704862af483478df410913465df3b6321bbfa[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Sep 14 13:23:19 2021 +0100

    updating the release notes
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 8b988b3e6c65262ed68b4f8f4fe652a95159f0ad[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Sep 14 13:16:58 2021 +0100

    Creating the High Availability guide
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 38c1f1b444b558e31c3da62d4bcda91774e6f7ef[m
Merge: 6aa643fb 41ebb827
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Sep 12 08:06:10 2021 -0400

    Merge branch 'main' of https://github.com/chipzoller/kyvernowebsite into main

[33mcommit 6aa643fbaa4505f6c007e07a1226314c6109d7f2[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Sep 1 10:19:48 2021 -0400

    add apply example
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit eb597f59e044dda4c99b0ea43ebf18a10abe0e29[m
Merge: e759713a acc02239
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Sep 10 09:05:29 2021 -0400

    Merge pull request #287 from Anita-ihuman/blogpost
    
    uploaded new blogpost

[33mcommit acc02239ba8987c48092100d500714cd1bc88103[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Fri Sep 10 09:05:35 2021 +0100

    uplaoded new blogpost
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit e759713adb41661c1b27a3baee73ef4a5cb48f72[m
Merge: 45976977 e15ccf1d
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Sep 8 09:04:17 2021 -0400

    Merge pull request #284 from Anita-ihuman/release-notes
    
    Release notes

[33mcommit 459769770c3f0d103c3483d072a05835b967d8d0[m
Merge: 857f16eb 89c8dec2
Author: shuting <shutting06@gmail.com>
Date:   Tue Sep 7 21:20:14 2021 -0700

    Merge pull request #285 from Anita-ihuman/behaviou-bot-config
    
    Created new PR for Behaviour bot config files

[33mcommit e15ccf1dbd0e5b3e77544c547441d977d5e9d7d3[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Sep 7 10:01:11 2021 +0100

    fixed and changed issues in v1.4.0 - v1.4.2
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 89c8dec22ed19739af4d7c5c6d8deff361ffff18[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Sat Sep 4 21:38:10 2021 +0100

    removed reoccuring mistake
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 697f7dbfffb6619b0359141c55485cb3af2fe1ee[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Sat Sep 4 10:35:16 2021 +0100

    creating new branch for config files.
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit a30d4cf97c261e6c89dbc60f27404a41bcac73a0[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Sat Sep 4 10:23:55 2021 +0100

    adding changes in sepeperate branches
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit b28745751c1261eef1449f99601f54ef4476873a[m
Merge: 1e404e4a 857f16eb
Author: Anita-ihuman <62384659+Anita-ihuman@users.noreply.github.com>
Date:   Thu Sep 2 09:15:35 2021 +0100

    Merge branch 'kyverno:main' into main

[33mcommit 41ebb827efe054bcb34011b5aa606dd366c9b74c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Sep 1 10:19:48 2021 -0400

    add apply example
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 857f16eb1c3ec4788775ca9534da5150a179ed4f[m
Merge: 37fe8005 c9855d3a
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Aug 31 22:28:18 2021 -0700

    Merge pull request #269 from chipzoller/main
    
    v1.4.2 updates

[33mcommit c9855d3afca233503c9341a410c44ee294936d3f[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Aug 30 18:23:49 2021 -0400

    add section on ownerReferences
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 1e404e4af0499995017d553cdd4ee2d83b65212e[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Mon Aug 30 22:16:00 2021 +0100

    correcting the build error
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit d3cc0bbe1a23fef158d766236298c1f3c0325be9[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Mon Aug 30 10:34:55 2021 +0100

    creating new section for release notes
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 10729f0aa3866d271fd2bc42ddc47af241837741[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Fri Aug 27 22:56:36 2021 +0100

    created new sections for release notes
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 737974db42497d5aa3ee616bd992316ae665cd4a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Aug 27 13:39:57 2021 -0400

    CLI updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 22a452d07884339988a205938a1fcc40476fbee2[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Aug 26 10:51:51 2021 -0400

    fix `get policyreport` flag
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 8e1bb31c387abee280c2944357f11a21c077efea[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Aug 24 17:13:14 2021 -0400

    Add troubleshooting steps for resource utilization
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 383ba95c7eb8cf9a26e5202267104de6b47786b6[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Aug 24 16:54:26 2021 -0400

    add example using any and all
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 37fe80051507e93e216f02112619b54b5d2bac18[m
Merge: 6c25461a 2d3ae411
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Aug 24 11:03:01 2021 -0700

    Merge pull request #266 from Anita-ihuman/main
    
    created an issue template

[33mcommit 0555709966f006ebecb64bbf4ca584f739853c17[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Aug 24 11:58:57 2021 -0400

    add unresolved vars
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b68fbb1441721ff89b558e5dfd48df969cddf9dd[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Aug 24 11:49:44 2021 -0400

    update with new generate behavior for deleted policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 505659650337944035529eb17250ce8a5b695e0b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Aug 24 08:55:26 2021 -0400

    tweak policies page message
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2b18d666d01203d30c61421305c0e7fec80a4147[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Aug 24 08:48:08 2021 -0400

    update docsy
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2d3ae411c3cdccd086d2a856a4e0a888d8709049[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Tue Aug 24 01:39:50 2021 +0100

    updated PR
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 503c7de6903629d76bb4bbef8b8595ff6d256b33[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Mon Aug 23 16:56:07 2021 +0100

    created a PR template for the repository
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 6c3c49296f0cbad4e0ca96afca123bda42a30bba[m
Author: Anita-ihuman <charlesanita403@gmail.com>
Date:   Mon Aug 23 16:35:29 2021 +0100

    created an issue template
    
    Signed-off-by: Anita-ihuman <charlesanita403@gmail.com>

[33mcommit 7b4c48e66fe3df15e2615591d052716a4927efc9[m
Merge: 6c25461a 845fe276
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Aug 23 08:40:02 2021 -0400

    Merge branch 'main' of https://github.com/chipzoller/kyvernowebsite into main

[33mcommit 6c25461a01d75e839ee3323185a34c9bd5a42d39[m
Merge: 4996e8e8 95b63f3c
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Aug 22 20:38:29 2021 -0700

    Merge pull request #255 from onweru/policies-page-enhancements
    
    Policies page enhancements

[33mcommit 4996e8e8671bd1f8cbd2edc44af21b67c799fcfb[m
Merge: 83ee95f1 0532c5a5
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Aug 22 20:35:58 2021 -0700

    Merge pull request #258 from ShubhamPalriwala/navbar-drop-down
    
    Drop down nav bar for mobile

[33mcommit 845fe27620865f8f61808c35499f271597126e06[m
Merge: d8699d59 83ee95f1
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Aug 22 14:18:01 2021 -0400

    Merge branch 'kyverno:main' into main

[33mcommit 83ee95f1a81fc7d0a03e4f11cb5899443f909a43[m
Merge: ccfe9e8b d6f03ede
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Aug 20 14:16:57 2021 -0400

    Merge pull request #263 from ShubhamPalriwala/responsive-resource-page
    
    Video thumbnails made responsive

[33mcommit ccfe9e8b0791ec6630c946b6d655f8ed76200900[m
Merge: 3f5b3a6c ae64de84
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Aug 20 14:16:02 2021 -0400

    Merge pull request #262 from ShubhamPalriwala/blog
    
    Added new Blog

[33mcommit d6f03edec66d622a35f93b21a5246c56df7ad9e8[m
Author: ShubhamPalriwala <spalriwalau@gmail.com>
Date:   Fri Aug 20 21:43:18 2021 +0530

    fix: responsive video-thumbnails
    
    Signed-off-by: ShubhamPalriwala <spalriwalau@gmail.com>

[33mcommit ae64de8400a4c04d0a8b966a487214368412851e[m
Author: ShubhamPalriwala <spalriwalau@gmail.com>
Date:   Fri Aug 20 20:59:13 2021 +0530

    add: blog
    
    Signed-off-by: ShubhamPalriwala <spalriwalau@gmail.com>

[33mcommit d8699d596ce46eecbadf035c1770c09d617c53b5[m
Merge: 820e4cf9 3f5b3a6c
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Aug 19 08:14:44 2021 -0400

    Merge branch 'kyverno:main' into main

[33mcommit 820e4cf973826f5a7acc166dd95b32f87d283759[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Aug 19 08:14:03 2021 -0400

    Squashed commit of the following:
    
    commit 3f5b3a6ca69921b2d03e8ca00e40ff9a3062a3cc
    Merge: 5d3bcd8 c675427
    Author: Chip Zoller <chipzoller@gmail.com>
    Date:   Thu Aug 19 08:06:39 2021 -0400
    
        Merge pull request #254 from treydock/helm-crds
    
        Document Kyverno CRDs Helm chart
    
    commit c675427d7104d4c89451eb0db5a03eda505d86a7
    Author: Trey Dockendorf <tdockendorf@osc.edu>
    Date:   Wed Aug 18 11:32:16 2021 -0400
    
        Adjust version and add backup/restore steps
    
        Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>
    
    commit 0c18c2a2a0bde6922ef53ccebc77ef226c9938d1
    Author: Trey Dockendorf <tdockendorf@osc.edu>
    Date:   Fri Aug 13 10:35:58 2021 -0400
    
        Document Kyverno CRDs Helm chart
    
        Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>
    
    commit 5d3bcd82ab341e540776b01f74338d0837e6b9d1
    Merge: d9955ed 87d93a1
    Author: Chip Zoller <chipzoller@gmail.com>
    Date:   Wed Aug 18 08:59:15 2021 -0400
    
        Merge pull request #253 from NoSkillGirl/main
    
        Removing Cleanup Webhook Configurations from the website doc
    
    commit d9955ede37aceeef102d59edf22825586d6027f5
    Merge: 2239e20 ea70568
    Author: shuting <shutting06@gmail.com>
    Date:   Mon Aug 16 12:59:15 2021 -0700
    
        Merge pull request #257 from ShubhamPalriwala/cncf-logo-responsiveness
    
        Fix: Responsive CNCF logo
    
    commit ea70568c5db04ee8100f61a9e3828370597cf084
    Author: ShubhamPalriwala <spalriwalau@gmail.com>
    Date:   Mon Aug 16 13:02:27 2021 +0530
    
        fix: responsive cncf logo
    
        Signed-off-by: ShubhamPalriwala <spalriwalau@gmail.com>
    
    commit 87d93a1c574ba558b6117119c5c5a222a3b8d831
    Author: NoSkillGirl <singhpooja240393@gmail.com>
    Date:   Fri Aug 13 11:52:01 2021 +0530
    
        removing Clean up Webhook Configurations
    
        Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>
    
    commit 2239e20ad8beebcadef250f3534cbc3f7b586155
    Merge: 19ed3a0 ca9ff1d
    Author: Jim Bugwadia <jim@nirmata.com>
    Date:   Thu Aug 12 05:35:21 2021 -0700
    
        Merge pull request #240 from yashvardhan-kukreja/update-docs-for-metrics
    
        updated: metrics-related docs with respect to new metric updates
    
    commit 19ed3a0cc52c700b6372d6fc4c5f99056224a4a8
    Merge: 38babd9 b665326
    Author: Jim Bugwadia <jim@nirmata.com>
    Date:   Wed Aug 11 21:56:06 2021 -0700
    
        Merge pull request #246 from chipzoller/main
    
        [main] README updates; remove reference to Kyverno CM; render policies
    
    commit ca9ff1d69b3ce3f2fbfc91d4992ecd764b44ab1c
    Author: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>
    Date:   Wed Aug 11 08:54:15 2021 +0530
    
        updated: metrics-related docs with respect to new metric updates
    
        Signed-off-by: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>

[33mcommit 3f5b3a6ca69921b2d03e8ca00e40ff9a3062a3cc[m
Merge: 5d3bcd82 c675427d
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Aug 19 08:06:39 2021 -0400

    Merge pull request #254 from treydock/helm-crds
    
    Document Kyverno CRDs Helm chart

[33mcommit c675427d7104d4c89451eb0db5a03eda505d86a7[m
Author: Trey Dockendorf <tdockendorf@osc.edu>
Date:   Wed Aug 18 11:32:16 2021 -0400

    Adjust version and add backup/restore steps
    
    Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>

[33mcommit 0c18c2a2a0bde6922ef53ccebc77ef226c9938d1[m
Author: Trey Dockendorf <tdockendorf@osc.edu>
Date:   Fri Aug 13 10:35:58 2021 -0400

    Document Kyverno CRDs Helm chart
    
    Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>

[33mcommit 5d3bcd82ab341e540776b01f74338d0837e6b9d1[m
Merge: d9955ede 87d93a1c
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Aug 18 08:59:15 2021 -0400

    Merge pull request #253 from NoSkillGirl/main
    
    Removing Cleanup Webhook Configurations from the website doc

[33mcommit d9955ede37aceeef102d59edf22825586d6027f5[m
Merge: 2239e20a ea70568c
Author: shuting <shutting06@gmail.com>
Date:   Mon Aug 16 12:59:15 2021 -0700

    Merge pull request #257 from ShubhamPalriwala/cncf-logo-responsiveness
    
    Fix: Responsive CNCF logo

[33mcommit 0532c5a5397609e6f93fc185f20e3b1f14d5dfd9[m
Author: ShubhamPalriwala <spalriwalau@gmail.com>
Date:   Mon Aug 16 20:47:51 2021 +0530

    feat: drop down navbar on non-desktop displays
    
    Signed-off-by: ShubhamPalriwala <spalriwalau@gmail.com>

[33mcommit ea70568c5db04ee8100f61a9e3828370597cf084[m
Author: ShubhamPalriwala <spalriwalau@gmail.com>
Date:   Mon Aug 16 13:02:27 2021 +0530

    fix: responsive cncf logo
    
    Signed-off-by: ShubhamPalriwala <spalriwalau@gmail.com>

[33mcommit 95b63f3ca9d1af786aac1bbe327d2240b4f16936[m
Author: weru <fromweru@gmail.com>
Date:   Fri Aug 13 17:48:24 2021 +0300

    add back to all policies button
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 77b84019af12e604751847e6656b16aff5f1d6ba[m
Author: weru <fromweru@gmail.com>
Date:   Fri Aug 13 17:16:42 2021 +0300

    include url queries only on list page
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 594338d6dc5d119acb3809b1ea5e1257c5706eab[m
Author: weru <fromweru@gmail.com>
Date:   Fri Aug 13 17:09:44 2021 +0300

    restyle filter icon
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 085e2b9590220a7037148847fd5c5d62b88d01b9[m
Author: weru <fromweru@gmail.com>
Date:   Fri Aug 13 17:09:34 2021 +0300

    make filter icon toggleable
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit db1ab2f8d70c20c9309c6d346966df58cdf1b1dd[m
Author: weru <fromweru@gmail.com>
Date:   Fri Aug 13 17:09:05 2021 +0300

    use svg for filter icon
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit d2aababab08715d22b6add7269b00ef3a0a536e5[m
Author: weru <fromweru@gmail.com>
Date:   Fri Aug 13 16:38:18 2021 +0300

    increase policy page content maximum horizontal width
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 87d93a1c574ba558b6117119c5c5a222a3b8d831[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Fri Aug 13 11:52:01 2021 +0530

    removing Clean up Webhook Configurations
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 2239e20ad8beebcadef250f3534cbc3f7b586155[m
Merge: 19ed3a0c ca9ff1d6
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Aug 12 05:35:21 2021 -0700

    Merge pull request #240 from yashvardhan-kukreja/update-docs-for-metrics
    
    updated: metrics-related docs with respect to new metric updates

[33mcommit 19ed3a0cc52c700b6372d6fc4c5f99056224a4a8[m
Merge: 38babd98 b665326f
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Aug 11 21:56:06 2021 -0700

    Merge pull request #246 from chipzoller/main
    
    [main] README updates; remove reference to Kyverno CM; render policies

[33mcommit ca9ff1d69b3ce3f2fbfc91d4992ecd764b44ab1c[m
Author: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>
Date:   Wed Aug 11 08:54:15 2021 +0530

    updated: metrics-related docs with respect to new metric updates
    
    Signed-off-by: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>

[33mcommit b665326f0c49e6c1ee70996136be96e61ca51d1e[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Aug 10 18:37:18 2021 -0400

    render policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit d84d78bc27ed2539290422861d89ce074bf8ad41[m
Merge: 42eaa537 38babd98
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Aug 10 18:19:11 2021 -0400

    Merge branch 'kyverno:main' into main

[33mcommit 38babd9869eb59dedf61e396f07777ed3ca9eff7[m
Merge: b08d6d83 73f6cb7f
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Aug 10 09:20:12 2021 -0400

    Merge pull request #249 from dlorenc/cosigntypo
    
    Fix typo in cosign tutorial.

[33mcommit 73f6cb7fd71336c4f18f9d9928bebd361705db0d[m
Author: Dan Lorenc <dlorenc@google.com>
Date:   Tue Aug 10 08:17:25 2021 -0500

    Fix typo in cosign tutorial.
    
    The actual example images are "test-verify-image", but the docs and
    policy use "test-image-verify".
    
    Signed-off-by: Dan Lorenc <dlorenc@google.com>

[33mcommit 42eaa5372f1aefa7203ca3672120d576e0b3c2c9[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Aug 9 19:15:29 2021 -0400

    add webhook config; fix more cm refs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b08d6d8356bd46b8d55ab52324a9cfa243399b01[m
Merge: c25d6d55 af3eea2e
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Aug 9 18:36:34 2021 -0400

    Merge pull request #241 from treydock/duration-operator
    
    Document duration operators

[33mcommit ac77e2b3a7a299c3a1b2798025dd6c66ab3eecf5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Aug 9 18:25:27 2021 -0400

    remove reference to Kyverno CM name
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit af3eea2ea3e9609c98d9c99e1ec98e65f46c1fc0[m
Author: Trey Dockendorf <tdockendorf@osc.edu>
Date:   Mon Aug 9 09:14:31 2021 -0400

    Fix wording, make descriptions match
    
    Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>

[33mcommit b0b037a4a0289f97dd08164d21b11c44530e288c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Aug 9 09:12:40 2021 -0400

    README updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit c25d6d5575987f7f387f046b8dcdeb9c37fbb6af[m
Merge: 4f7b366d fcbd9fcb
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Aug 8 23:49:19 2021 -0700

    Merge pull request #237 from RinkiyaKeDad/any_all_docs
    
    updating documentation to reflect any and all tags

[33mcommit 4f7b366d3c2276257ab187e058c4a1a8fbe39cf6[m
Merge: 3ed11280 a8fe966a
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Mon Aug 9 11:24:33 2021 +0530

    Merge pull request #196 from kyverno/helm_support
    
    customizable Helm release name

[33mcommit 3ed11280d929951571582e064257fb6e5461e0fc[m
Merge: d75ac107 5b31a30b
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Aug 8 17:28:23 2021 -0700

    Merge pull request #243 from chipzoller/main
    
    policy updates

[33mcommit 5b31a30ba7fbff34559d6522f80ee1e3a9e14f3f[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Aug 8 20:19:54 2021 -0400

    policy updates
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 68357b3572a7f50c2a3864c81d9d4111ea0e07ab[m
Author: Trey Dockendorf <tdockendorf@osc.edu>
Date:   Sun Aug 8 10:20:01 2021 -0400

    Fix wording
    
    Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>

[33mcommit 344373a9094736b7888d883ead75e5b8dffbbb73[m
Author: Trey Dockendorf <tdockendorf@osc.edu>
Date:   Mon Aug 2 10:29:35 2021 -0400

    Fix typo in minversion
    
    Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>

[33mcommit 7521d19b19b7ddb475172c59b332c9840e6a4203[m
Author: Trey Dockendorf <tdockendorf@osc.edu>
Date:   Mon Aug 2 09:17:25 2021 -0400

    Better policy description
    
    Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>

[33mcommit 5549121ff1307906d6f9f26611cbce7db6a63950[m
Author: Trey Dockendorf <tdockendorf@osc.edu>
Date:   Mon Aug 2 09:12:11 2021 -0400

    Better description for duration operators
    Example policy should only be audit, not enforce by default
    
    Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>

[33mcommit d75ac10785492d71a9c7ac7f0616d70aca8bef5a[m
Merge: aa02e79e 70be2bb3
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Aug 1 07:53:59 2021 -0700

    Merge pull request #236 from JimBugwadia/main
    
    add release versioning instructions

[33mcommit 70be2bb3e6cc02c8381cc6ab1f963d1caf7d7760[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Jul 31 16:59:36 2021 -0700

    fix URL and clarify instructions. also re-ordered sections to prioritize most frequently used.
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 017884640953c6cbc125c886cdec43c2521a7a51[m
Author: Trey Dockendorf <tdockendorf@osc.edu>
Date:   Fri Jul 30 20:34:04 2021 -0400

    Document duration operators
    
    Signed-off-by: Trey Dockendorf <tdockendorf@osc.edu>

[33mcommit a98f9e133108886b037bcc7c6110cdea8d81d9ab[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jul 30 14:26:53 2021 -0700

    fix link and add multi-PR instructions
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit e7ce14b6cecbae0da472272a3909af15c6f8297f[m
Author: weru <fromweru@gmail.com>
Date:   Fri Jul 30 17:15:51 2021 +0300

    add a note
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit fcbd9fcb2c2c9af1a947d3012856d0a5127047bb[m
Author: RinkiyaKeDad <arshsharma461@gmail.com>
Date:   Fri Jul 30 18:28:24 2021 +0530

    fixed typo
    
    Signed-off-by: RinkiyaKeDad <arshsharma461@gmail.com>

[33mcommit 4caa3473e1e446ad7708c7d23302842c40478f49[m
Author: RinkiyaKeDad <arshsharma461@gmail.com>
Date:   Fri Jul 30 17:11:15 2021 +0530

    reverted examples and highlighted that only one of any or all to be specified
    
    Signed-off-by: RinkiyaKeDad <arshsharma461@gmail.com>

[33mcommit 84a1e4739baf72d9eed44a4796da03c332ae02c7[m
Author: RinkiyaKeDad <arshsharma461@gmail.com>
Date:   Fri Jul 30 10:58:28 2021 +0530

    updated docs to reflect any all changes
    
    Signed-off-by: RinkiyaKeDad <arshsharma461@gmail.com>

[33mcommit 9312cb780229eb1759bd050a8eef76cb1f48dd87[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 29 16:22:03 2021 -0700

    add release versioning instructions
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit aa02e79ec9a40965e06420b9750628b4b1f9c137[m
Merge: e1b09f37 392e638f
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 29 15:38:05 2021 -0700

    Merge pull request #233 from JimBugwadia/main
    
    merge v1.4.2 to main

[33mcommit 392e638f1aaf00b62695dfd3f7415bd07954220b[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 29 01:43:40 2021 -0700

    update to 1.4.2
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 62114fd1af604fb7798d72b1df9f8e5eda40c0ba[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 29 01:39:27 2021 -0700

    update versions
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 16c8520688d87fb57415e174f835a1e27c27b091[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 29 01:34:12 2021 -0700

    update versions
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 5c6c9f27ecc7e9e3e6ede6c00c999f484ba2b778[m
Merge: 58e57e53 e1b09f37
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 29 01:23:59 2021 -0700

    merge main
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 58e57e537124bbe368a74a40f0608913ce39fb83[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 29 01:22:11 2021 -0700

    update version dropdown
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit e1b09f37234c671a2de4427d0f23e228e1c35be6[m
Merge: a1e4340c dad951f2
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 29 00:18:19 2021 -0700

    Merge pull request #232 from chipzoller/main
    
    Website fixes

[33mcommit dad951f29aa57bae9bc470a7cac28484cbc2d36a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 28 16:16:48 2021 -0400

    add blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 518102dd5740dff8c4d1a5ec1d852ea44b64bda0[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 28 15:48:40 2021 -0400

    Document existence of request.roles and request.clusterRoles
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit cad0d129051fe0714f5d1d95a6aa09f4e141a755[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 28 15:42:45 2021 -0400

    add note about event on violating resources
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 3005072e71006d64b8b7632d2d67bd3f3a6a7b6b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 28 15:36:32 2021 -0400

    update generate bindings with SA name; add note on custom generations
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 387027550d6aaee2d65901712e57b80723225add[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 28 15:23:18 2021 -0400

    expand and clarify anyPattern with example
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit e2efc7e46abe76f2a85c2ca76548e78ca70d73f7[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 28 15:13:20 2021 -0400

    minor note add to label_match function
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 606c10689f328e576ba1a766404ce26a4a935725[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 28 15:07:29 2021 -0400

    clarify negation anchor
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 130e36c6e1471e30fa7ea3e825dbfec8764f02c5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 28 15:04:20 2021 -0400

    fix comment in "match-critical-app"
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 8521123e22e36bd59f2cc6e702e12a3065d72186[m
Merge: 81bf0b0c 10d76c3d
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 18:08:13 2021 -0700

    Merge branch 'kyverno:release-1-4-2' into release-1-4-2

[33mcommit 81bf0b0ce95ebcccbcf142163220338f670148e6[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 18:07:18 2021 -0700

    remove empty tip
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 10d76c3dc77b6591d3ceee16290a7552fb3032dd[m
Merge: eaf2d31c 60f33390
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 18:00:44 2021 -0700

    Merge pull request #223 from JimBugwadia/release-1-4-2
    
    update imageVerify

[33mcommit 60f3339058c1827f147fd97fec02fb4f9f6418f8[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 17:57:22 2021 -0700

    add Cosign OCI registry link
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit fbb517d8fae71e150f6301e90279a71a1a777a1b[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 15:36:27 2021 -0700

    more fixes
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit ad781c77d8124d0fa2da50023a1f217785d49cda[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 14:57:30 2021 -0700

    more fixes
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 9b64fd37a556a10749cec6641dfeae67ee61aab7[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 13:59:26 2021 -0700

    fixes from review comments
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit a1e4340c7f9c7f8b2407805c276f99b84ee103f3[m
Merge: 8d38c572 513bf623
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 13:51:20 2021 -0700

    Merge pull request #215 from kyverno/add_versioning
    
    add releases

[33mcommit 8d38c572e2304960fde3d683a9e79cc5633040de[m
Merge: e3aa3e72 e470f418
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 13:51:00 2021 -0700

    Merge pull request #227 from onweru/main
    
    Allow crawlers to resume indexing pages

[33mcommit e470f418da119621cf50879d41b27bad6126bbd9[m
Author: weru <fromweru@gmail.com>
Date:   Tue Jul 27 23:34:20 2021 +0300

    remove custom robots.txt file
    
    fixes kyverno/website#217

[33mcommit e3aa3e7239d7b889355778b45aa4eebcb8356cb0[m
Merge: 6b5d5fb8 0d8a64a5
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 08:53:54 2021 -0700

    Merge pull request #224 from fjogeleit/main
    
    Update Policy Reporter Repository

[33mcommit 3d9fed2020d14ce15841169cef9791ab5c0806c2[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 01:57:45 2021 -0700

    update examples
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 0d8a64a5de79aee83d4b4f3a8f5fbd6a3b080c57[m
Author: Frank Jogeleit <fj@move-elevator.de>
Date:   Tue Jul 27 09:54:36 2021 +0200

    Update Policy Reporter Repository
    
    Signed-off-by: Frank Jogeleit <fj@move-elevator.de>

[33mcommit 47a3f986fadc085d4230bbb128f03a23e7952f88[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 27 00:21:30 2021 -0700

    update imageVerify
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 6b5d5fb82261b2459b42b2d20e44f857796f28b6[m
Merge: d7a747e3 fdd63fe6
Author: shuting <shutting06@gmail.com>
Date:   Fri Jul 23 10:54:57 2021 -0700

    Merge pull request #193 from RinkiyaKeDad/scored_docs
    
    adding a note about the scored annotation

[33mcommit d7a747e3eaa4f3633143b9127c6b66823043ea18[m
Merge: 99525b24 8a84f059
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Fri Jul 23 16:31:07 2021 +0530

    Merge pull request #221 from RinkiyaKeDad/clusterrole_fixes
    
    fix clusterRoles casing and usage in selecting resources page

[33mcommit 8a84f0595eea591bb4234264bdbad40586fbb332[m
Author: RinkiyaKeDad <arshsharma461@gmail.com>
Date:   Fri Jul 23 16:25:48 2021 +0530

    fix clusterrole uses in match and exclude
    
    Signed-off-by: RinkiyaKeDad <arshsharma461@gmail.com>

[33mcommit 99525b2499911597246f7a5384f208a4cb6bbae5[m
Merge: d43bd7eb 603f6fc6
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 22 01:10:09 2021 -0700

    Merge pull request #218 from MarcusNoble/patch-1
    
    add note about wildcard support on conditions

[33mcommit 603f6fc68a736a3ba22b2a4b17a4fb0a6f69c32a[m
Author: Marcus Noble <m.noble@elsevier.com>
Date:   Thu Jul 22 08:44:58 2021 +0100

    add note about wildcard support on conditions
    
    See https://github.com/kyverno/kyverno/issues/2165 for reference.
    
    Signed-off-by: Marcus Noble <m.noble@elsevier.com>

[33mcommit eaf2d31c6aff1c1ea907a37ba2037541dbc8c31e[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 20 23:59:40 2021 -0700

    test
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit c53e3846e4aa7bbfd85889f3d3e2f5b7d7c83158[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 20 23:42:13 2021 -0700

    start image verification
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 329b0781f26ca6567b8aa4da62e4363663f1b43a[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 20 23:41:45 2021 -0700

    start image verification
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 513bf623fbef420656d669cf8c27d5cc054012e1[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 20 12:53:48 2021 -0700

    add releases
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit d43bd7eb46011640dce57cb1942b79809d1e2bf2[m
Merge: 7dafdc8b 312c8cfc
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 20 11:32:45 2021 -0700

    Merge pull request #214 from kyverno/add_arch_diagrams
    
    add arch and install diagrams and shorten headings

[33mcommit 312c8cfc4daaa710e0d5163113bd79dc6f51d973[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 20 11:23:56 2021 -0700

    add image
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 2c0e98417b489b10a86d7e239f541ccc4cc571cd[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 20 10:21:05 2021 -0700

    add line breaks
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 5f8f959d26d484f6c492f9d3f9257dd38783970b[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jul 20 10:16:45 2021 -0700

    add arch and install diagrams and shorten headings
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 7dafdc8b974620ac1d9e691abdfde65dabdb81ec[m
Merge: 33d9add0 81866024
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jul 19 12:09:08 2021 -0700

    Merge pull request #213 from kyverno/render/check_deprecated_apis
    
    render policy sample check_deprecated_apis

[33mcommit 81866024fa37ddd357e76bc959efd17a3ecc870c[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jul 19 12:07:04 2021 -0700

    re-render
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit ceeeb0ca4a76e53d31f95a306157cc4476668904[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jul 19 10:56:50 2021 -0700

    render policy sample check_deprecated_apis
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 33d9add04b9b2302a6bfd943b4ee12a3d05de9e5[m
Merge: 4925f33b e2627439
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jul 15 15:51:43 2021 -0700

    Merge pull request #204 from chipzoller/main
    
    render new policies

[33mcommit e2627439a036f4926dcd4302c3d1f07b77cf7f5b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 14 15:14:28 2021 -0400

    fix logic
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4925f33b1592c45ea64984aecdd0d23023ae6f21[m
Merge: e4b41b25 2b268888
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jul 11 23:58:28 2021 -0700

    Merge pull request #206 from kyverno/bug/test_resourceName
    
    fix ResourceName for test command

[33mcommit 2b26888840c29e9c5b93e8af07d8567ee2b52b54[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Mon Jul 12 12:21:48 2021 +0530

    fix ResourceName for test command

[33mcommit 22723ec4c67fa68bc0b5ae2eb07f0c581b5bbf02[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jul 10 10:54:24 2021 -0400

    render new policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit e4b41b2550bfc4cd8e87980d97a16ac62f874333[m
Merge: 7aaa0255 782936fe
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 7 14:53:26 2021 -0400

    Merge pull request #202 from chipzoller/main
    
    fix note about replicas

[33mcommit 7aaa02559c92dfb9ac489e5e790fd7bb11f9a886[m
Merge: c61068f9 af5b77af
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 7 07:56:20 2021 -0400

    Merge pull request #200 from RinkiyaKeDad/docs_for_names
    
    updating docs to reflect deprecation of resources.name

[33mcommit 782936fe281c3f1ab82bab9b85ce93800b5175ea[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jul 7 07:51:05 2021 -0400

    fix note about replicas
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit af5b77af651056ab7483ad899ce9d1f5b417f4f2[m
Author: RinkiyaKeDad <arshsharma461@gmail.com>
Date:   Tue Jul 6 19:23:42 2021 +0530

    fixed yaml list format and update message about release
    
    Signed-off-by: RinkiyaKeDad <arshsharma461@gmail.com>

[33mcommit c61068f9951b316d56ceffe605a63bfc52bcda82[m
Merge: 3bcc4a7e 18587b19
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Jul 6 07:48:15 2021 -0400

    Merge pull request #192 from viveksahu26/doccs-fix-examples
    
    Added kind attribute in resources element in one of the example of Po…

[33mcommit 8ca843329b77f84d046f75ff8ba06f304353262b[m
Author: RinkiyaKeDad <arshsharma461@gmail.com>
Date:   Tue Jul 6 11:46:03 2021 +0530

    updating docs to reflect deprecation of resources.name
    
    Signed-off-by: RinkiyaKeDad <arshsharma461@gmail.com>

[33mcommit fdd63fe643e54b7da536264b5a61b0525f8b1ada[m
Merge: 6919ba49 3bcc4a7e
Author: Arsh Sharma <56963264+RinkiyaKeDad@users.noreply.github.com>
Date:   Mon Jul 5 11:36:45 2021 +0530

    Merge branch 'main' into scored_docs

[33mcommit 3bcc4a7e0dd94c208987b7afccc77e8023d2f7b8[m
Merge: 0a627de3 a4b091cf
Author: shuting <shutting06@gmail.com>
Date:   Thu Jul 1 11:01:42 2021 -0700

    Merge pull request #197 from vfarcic/main
    
    Video

[33mcommit a4b091cfa04c9e95f49c8a3d52ed8e9f02cbf19c[m
Author: Viktor Farcic <viktor@farcic.com>
Date:   Thu Jul 1 17:08:51 2021 +0200

    OPA vs Kyverno
    
    Signed-off-by: Viktor Farcic <viktor@farcic.com>

[33mcommit a8fe966ac0c8602196818662dc2c6b757829f242[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Wed Jun 30 22:17:02 2021 +0530

    Change kyverno version

[33mcommit ecb06fc610b962e7ec2102c26bd01f3bf2305cfb[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Wed Jun 30 20:08:33 2021 +0530

    Fix typo

[33mcommit ffe649c4a6b6238ee0cae853deb3ee4dbe492a37[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Wed Jun 30 17:34:25 2021 +0530

    Fix typos

[33mcommit 9f26885249528fd0570a650ed639c30e0ae03307[m
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Wed Jun 30 14:54:12 2021 +0530

    customizable release name

[33mcommit 18587b1947b68821417af299ef1047d268b3c494[m
Author: viveksahu26 <vivekkumarsahu650@gmail.com>
Date:   Thu Jun 24 17:24:46 2021 +0530

    updated
    
    Signed-off-by: viveksahu26 <vivekkumarsahu650@gmail.com>

[33mcommit 6919ba49f9b2751edbb44bd7ca4ec29ed33a2cf1[m
Author: RinkiyaKeDad <arshsharma461@gmail.com>
Date:   Thu Jun 24 16:46:43 2021 +0530

    added default explanation
    
    Signed-off-by: RinkiyaKeDad <arshsharma461@gmail.com>

[33mcommit 558000292f5ecf9e211752a2c9edbb5fb83b67cd[m
Author: viveksahu26 <vivekkumarsahu650@gmail.com>
Date:   Thu Jun 24 08:21:02 2021 +0530

    indeted  properly in the test.yaml file
    
    Signed-off-by: viveksahu26 <vivekkumarsahu650@gmail.com>

[33mcommit 0a627de3b0959810f2281db18d1956428a6323b9[m
Merge: 2d273974 30630bdd
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Jun 23 14:29:21 2021 -0700

    Merge pull request #194 from kyverno/clarify_policy_report
    
    clarify use of policy report and add link to Policy Reporter

[33mcommit 30630bdd74ed94282d861b408c62f879882058e0[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Jun 23 12:01:47 2021 -0700

    reorganize tips
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 4eab152a44e3188972344666acea84debb075ca9[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Jun 23 11:50:36 2021 -0700

    clarify use of policy report and add link to Policy Reporter
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 4fc76c493de2d7dfbe93cfee06f0de647cc3e265[m
Author: RinkiyaKeDad <arshsharma461@gmail.com>
Date:   Wed Jun 23 11:55:00 2021 +0530

    typo fix
    
    Signed-off-by: RinkiyaKeDad <arshsharma461@gmail.com>

[33mcommit 12c93f25f754aade4110b57c831b16069d77ac9e[m
Author: RinkiyaKeDad <arshsharma461@gmail.com>
Date:   Wed Jun 23 11:53:54 2021 +0530

    adding a note about the scored annotation
    
    Signed-off-by: RinkiyaKeDad <arshsharma461@gmail.com>

[33mcommit 65aafe171dacf7182566b566a0e3fb8c622fe4f3[m
Author: viveksahu26 <vivekkumarsahu650@gmail.com>
Date:   Mon Jun 21 22:29:41 2021 +0530

    Added kind attribute in resources element in one of the example of Policy
    
    Signed-off-by: viveksahu26 <vivekkumarsahu650@gmail.com>

[33mcommit 2d27397440e15927a3e836c4263ffc55155bdad2[m
Merge: 92a3bce7 b68258f9
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jun 21 08:55:19 2021 -0400

    Merge pull request #191 from viveksahu26/viveksahu_26
    
    Updated the documentation of the Test section of Kyverno CLI

[33mcommit b68258f9e6475a844c8bc79a39b890c06db96e16[m
Author: viveksahu26 <vivekkumarsahu650@gmail.com>
Date:   Mon Jun 21 09:11:44 2021 +0530

    Updated the docmentation of Match Statements
    
    Signed-off-by: viveksahu26 <vivekkumarsahu650@gmail.com>

[33mcommit 26f75f918771686de19fd7938caff54d5bf41506[m
Author: viveksahu26 <vivekkumarsahu650@gmail.com>
Date:   Sun Jun 20 19:52:04 2021 +0530

    Updated the documentation of the Test section of Kyverno CLI
    
    Signed-off-by: viveksahu26 <vivekkumarsahu650@gmail.com>

[33mcommit 92a3bce7f3a38cb6fc269bead6d55be1daf348de[m
Merge: 80aa36ed e5e5fa12
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jun 18 18:01:10 2021 -0700

    Merge pull request #167 from vineethvanga18/doc-version-update
    
    Add kyverno 1.4 to matrix

[33mcommit 80aa36ed35142f6ad22b5ae576c6cb3e8e15641d[m
Merge: 764186a4 6ddb9551
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jun 18 18:00:58 2021 -0700

    Merge pull request #168 from valentinEmpy/main
    
    Add 'generateSuccessEvents' flag

[33mcommit 764186a40a41b2c7c6ededa903286e82cc238c02[m
Merge: 2fb0569c 5c6beaa5
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jun 18 18:00:35 2021 -0700

    Merge pull request #190 from kyverno/bugfix/184_update_metrics_docs
    
    update metric docs

[33mcommit 5c6beaa5afd19f6ddb0ff0cd673869ac2ff77013[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jun 18 09:19:04 2021 -0700

    fix typo
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit ae110c44d13be055778967436e096923a4e070af[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jun 18 00:18:52 2021 -0700

    update metric docs
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 2fb0569caa0d5ccd74d43a15ac7c6cf743a6bb93[m
Merge: fc2467ac 19eddda6
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jun 17 18:29:16 2021 -0700

    Merge pull request #189 from kyverno/bugfix/add_operators
    
    add missing operators

[33mcommit fc2467accb409c9ff98334e5a37e948d14ea0266[m
Merge: 7257c5c4 49d7c3b4
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jun 17 18:28:50 2021 -0700

    Merge pull request #187 from nuno-silva/fix-404
    
    fix broken link

[33mcommit 7257c5c4240502e49b854642cca38f42587b21b8[m
Merge: ca7a1f6b ffd01204
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jun 17 18:28:10 2021 -0700

    Merge pull request #188 from kyverno/bugfix/anchor_hdr_chopped
    
    fix anchor spacing with fixed header

[33mcommit 19eddda6d26b7b7944a57765b45fc88a4c7b2b87[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jun 17 18:23:03 2021 -0700

    add missing operators
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit ffd012046a5d06f19b6aaf4b204e98c0cc8c2906[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jun 17 18:08:33 2021 -0700

    fix anchor spacing with fixed header
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 49d7c3b48eceacbedfa665d4de54d321c3016616[m
Author: Nuno Silva <nuno.m.ribeiro.silva@tecnico.ulisboa.pt>
Date:   Wed Jun 16 15:08:23 2021 +0100

    fix broken link
    
    Signed-off-by: Nuno Silva <nuno.m.ribeiro.silva@tecnico.ulisboa.pt>

[33mcommit ca7a1f6b9c285206d328101cd2b8b3aa455e312a[m
Merge: 39b89d6d c44711a9
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jun 14 11:26:05 2021 -0700

    Merge pull request #170 from yashvardhan-kukreja/docs-for-kyverno-metrics
    
    added: docs for kyverno metrics

[33mcommit 39b89d6dc925303f42c22c3277262f7e765d0d17[m
Merge: e77b0900 48131399
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jun 14 10:51:56 2021 -0700

    Merge pull request #182 from kyverno/update_slack_links
    
    update slack links and help

[33mcommit e77b0900d92226aae2fd47d9bcad7021bcc6a92d[m
Merge: b49cee9a 5d54061c
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jun 14 10:51:36 2021 -0700

    Merge pull request #183 from vfarcic/main
    
    Video

[33mcommit 5d54061ca10efd7b574f5077edd49c89e35c178d[m
Author: Viktor Farcic <viktor@farcic.com>
Date:   Mon Jun 14 17:18:56 2021 +0200

    Video
    
    Signed-off-by: Viktor Farcic <viktor@farcic.com>

[33mcommit 481313999515055677df004e89cf763ee3efb62c[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jun 13 17:00:16 2021 -0700

    update slack links and help
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit b49cee9afc6a2d05e0e89971f67719ff2c253e17[m
Merge: 82fc6aa7 71446bba
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Jun 12 06:16:46 2021 -0700

    Merge pull request #180 from chipzoller/main
    
    render new policies

[33mcommit 71446bbacc5aadf9d9dc0310db2268fa0ed911b8[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jun 12 09:07:35 2021 -0400

    render new policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit e5e5fa129390f5d464511a2d74820c66b7e47c18[m
Author: vineethvanga18 <reddy.8@iitj.ac.in>
Date:   Sat Jun 12 18:33:01 2021 +0530

    update max kube version to 1.21
    
    Signed-off-by: vineethvanga18 <reddy.8@iitj.ac.in>

[33mcommit c44711a91b833fd01c81b95624f59910114bd70e[m
Author: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>
Date:   Sat Jun 12 18:03:47 2021 +0530

    updated: docs and rearranged the weights
    
    Signed-off-by: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>

[33mcommit 3d6e9bc475cbef4232fa6074cfd20e47f47fa7ac[m
Author: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>
Date:   Wed Jun 9 23:02:21 2021 +0530

    shortened titles
    
    Signed-off-by: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>

[33mcommit 82fc6aa776d0371ca0966b0b27d74298a7cd3125[m
Merge: 80557440 dbb2828c
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jun 10 11:53:51 2021 -0700

    Merge pull request #177 from chipzoller/main
    
    updates for 1.3.6

[33mcommit 4e7b0dddb945fe3594e6c4fe96aa18e2353dc50d[m
Author: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>
Date:   Thu Jun 3 09:05:48 2021 +0530

    added: docs for the dashboard
    
    Signed-off-by: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>

[33mcommit 3cec3eff9a1fc47abd110825441270bd2a8f170a[m
Author: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>
Date:   Wed Jun 2 06:17:26 2021 +0530

    added: docs for kyverno metrics
    
    Signed-off-by: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>

[33mcommit dbb2828c2a54c4e2c60d010aa65821b80acb7c5d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jun 9 08:40:07 2021 -0400

    update sample to show metadata object
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 80557440b5d398778b946ed2c040af52abc5cae7[m
Merge: c00f8027 39e5c318
Author: shuting <shutting06@gmail.com>
Date:   Mon Jun 7 12:17:50 2021 -0700

    Merge pull request #172 from yashvardhan-kukreja/issue-171/fix-local-hugo-builds
    
    fix: npm dependency bootstrap and hugo builds and executions

[33mcommit 2d0c511cd7f5418c5052afac834c417c853ad1c8[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Jun 7 08:48:42 2021 -0400

    updates for 1.3.6
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit c00f80274e5d6697b79a243a93b7c760eaaea26f[m
Merge: c02140a8 5e1fab9b
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jun 6 13:08:23 2021 -0700

    Merge pull request #175 from viveksahu26/viveksahu26
    
    updated Resource Definitions #173

[33mcommit 5e1fab9b18d893ae42c2a835dabb3773ea76c51b[m
Author: viveksahu26 <vivekkumarsahu650@gmail.com>
Date:   Sun Jun 6 08:46:35 2021 +0530

    updated Resource Definitions #173
    
    Signed-off-by: viveksahu26 <vivekkumarsahu650@gmail.com>

[33mcommit c02140a8ad943f9a33a08085a5c123e7f6685ea7[m
Merge: 5545f202 f20f6150
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jun 6 10:13:45 2021 -0700

    Merge pull request #176 from kyverno/feature/add_pss_controls2
    
    fix typo

[33mcommit f20f6150fd3cc7eae340dc0b4ae9ecb2094c8de1[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jun 6 10:05:55 2021 -0700

    fix typo
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 5545f2023aa7a38a241e9d5ded4f0fe86aa4e401[m
Merge: 28a6513e 39757430
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jun 6 09:56:59 2021 -0700

    Merge pull request #174 from kyverno/feature/add_pss_controls
    
    inline policy list

[33mcommit 39757430915ee7fa326af2c2342c2f0a14ffaaf5[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Jun 5 19:23:40 2021 -0700

    inline policy list
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 39e5c318eb291abbadcdc629e6b3a05a46e68ce1[m
Author: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>
Date:   Wed Jun 2 06:50:39 2021 +0530

    fix: npm dependency bootstrap and hugo builds and executions
    
    Signed-off-by: Yashvardhan Kukreja <yash.kukreja.98@gmail.com>

[33mcommit 6ddb9551cf916bd78946d2005861a90855cd3f7d[m
Author: Velkov <valentin.velkov@sap.com>
Date:   Mon May 31 09:10:35 2021 +0300

    Add 'generateSuccessEvents' flag
    
    Signed-off-by: Velkov <valentin.velkov@sap.com>

[33mcommit 28a6513e31ee0d3ee7e52f10a6b973473f5cabd5[m
Merge: 76549881 79595041
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat May 29 13:36:49 2021 -0700

    Merge pull request #164 from chipzoller/main
    
    Fix mobile menu regression on policies page

[33mcommit 7096f67de21634a7da4ab697dbcfdb64275c2db1[m
Author: Vineeth Reddy <reddy.8@iitj.ac.in>
Date:   Fri May 28 10:47:31 2021 +0530

    Add kyverno 1.4 to matrix
    
    Signed-off-by: vineethvanga18 <reddy.8@iitj.ac.in>

[33mcommit 7654988131da180261d87511bb2eefbe9adf0ad5[m
Merge: 7b3d55ae b97414c1
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed May 19 14:57:06 2021 -0700

    Merge pull request #166 from kyverno/render/new_policies
    
    render 1.3.6 policies

[33mcommit b97414c14514620736f4526ba2fce552c7e24249[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed May 19 14:23:02 2021 -0700

    merge and re-render
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit d97aefbe4d4e8be6110648ba257c2ee448b03e96[m
Merge: f43c3c78 7b3d55ae
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed May 19 11:50:47 2021 -0700

    re-render with 1.3.6
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit f43c3c7878c569993a7f3aef24fb11fde79dd063[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed May 19 11:31:23 2021 -0700

    render 1.3.6 policies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 7b3d55ae11d47381c541bdc25853191e5137a76a[m
Merge: 155113e4 8ae78862
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed May 19 11:29:41 2021 -0700

    Merge pull request #143 from vyankyGH/doc/kind
    
    Doc: match.resources.kinds mandatory

[33mcommit 79595041b0f066ad88e182b17fdc37aa6076fe32[m
Author: weru <fromweru@gmail.com>
Date:   Thu May 13 13:22:22 2021 -0400

    fix mobile filter menu regression
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 4f5ee55dee26340fb1f486b21d465909da9c1ad9[m
Merge: cf67d36c 155113e4
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed May 12 18:28:38 2021 -0400

    Merge branch 'kyverno:main' into main

[33mcommit cf67d36c9b5af110de61da5dbb6449e13064aded[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed May 12 18:28:06 2021 -0400

    Add more notes to extending filters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 155113e4f5056d7e7dce42d0e3a844f6dfea5d7d[m
Merge: 77b325a9 696e26d8
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed May 12 15:18:19 2021 -0700

    Merge pull request #163 from chipzoller/main
    
    fix filters

[33mcommit 696e26d83d911aaa4c173b585f728b679003baeb[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed May 12 18:15:40 2021 -0400

    fix filters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 77b325a9d5fdf9b597542067e70e30e25f8322bc[m
Merge: 00099a93 375a33ba
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed May 12 14:54:13 2021 -0700

    Merge pull request #162 from chipzoller/main
    
    Add subject to policy filters

[33mcommit 375a33ba6b0b4421c4f29314c82d83264274a495[m
Author: weru <fromweru@gmail.com>
Date:   Wed May 12 16:56:32 2021 -0400

    only add unique filters
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 15ef46f5d2c39f72ac01dd3ec9678681e3dc6d0a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed May 12 16:00:50 2021 -0400

    updates to scrape subject
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 00099a932ec6cc45be358dd6a722617ae1ef8661[m
Merge: 21d10e07 3643176b
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat May 8 13:44:55 2021 -0700

    Merge pull request #161 from kyverno/feature/160_add_stars_banner
    
    feature/160 add stars banner

[33mcommit 3643176bad0d65a208041ace4678e66f4a96aa33[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri May 7 13:47:48 2021 -0700

    add banner and update layouts
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 5d6ac96685cf3907f61fe4978823e54e8d42159f[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri May 7 13:35:48 2021 -0700

    fix community link
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 613dca03954e80e068a1650a6f36b06a28f07f3f[m
Merge: c0f603f4 21d10e07
Author: weru <fromweru@gmail.com>
Date:   Sun May 2 20:39:37 2021 +0300

    Merge branch 'main' of https://github.com/chipzoller/kyvernowebsite

[33mcommit c0f603f4ad43eceef7e8e4fedb596aa644b99adb[m
Author: weru <fromweru@gmail.com>
Date:   Sun May 2 20:38:58 2021 +0300

    enable array-like filter values
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 21d10e07722ed98914be829af0e434a9d21d0328[m
Merge: 83667aad 857eb9e4
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Apr 30 08:31:31 2021 -0700

    Merge pull request #157 from chipzoller/main
    
    render new policy

[33mcommit 857eb9e49b06ff2c4280092be705dea744a3e151[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Apr 30 10:58:41 2021 -0400

    render new policy
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 83667aadf35452705dd561f9be6b72e5fe892e58[m
Merge: 6512b46b 2381b82a
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Apr 30 07:44:06 2021 -0700

    Merge pull request #156 from chipzoller/main
    
    Render new policies; filter updates

[33mcommit 2381b82a01c8fd3ec59a4643e45e8f798e545fb8[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Apr 30 08:32:44 2021 -0400

    update filter title to "Minimum Version"
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bbac62340651bc39dc7b980e4366da9a0aeca448[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 30 00:45:19 2021 +0300

    list version on the UI
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 61797bf518b857dea16d39653ebe0ad414c13159[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 30 00:41:31 2021 +0300

    add version inside  the filter index
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 5bf0e15fd23a0ed1d71518f949a011168d52532c[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 30 00:39:33 2021 +0300

    scrape minversion value from annotations
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 9efa8597a14c260de658be28a362cb0ba991b576[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 30 00:38:50 2021 +0300

    generate page
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit d41ad96d2806e07fab901f4e087bb62618925419[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 30 00:37:46 2021 +0300

    cleanu up
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit e760b9e41a918c71a37f0fe8c183ca2574ab1af1[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 30 00:36:38 2021 +0300

    clean up
    
    Signed-off-by: weru <fromweru@gmail.com>

[33mcommit 6512b46b94de8812c8323ecd5647cabbd6b62bff[m
Merge: a13e9ed1 3e4253c0
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Apr 26 09:01:05 2021 -0700

    Merge pull request #154 from gimlet-io/main
    
    Blog post: Mirroring environments with gitops and Kyverno

[33mcommit 3e4253c075bbc21068fc46e3b5fbdd2ecb9055e4[m
Author: Laszlo Fogas <laszlo@laszlo.cloud>
Date:   Mon Apr 26 14:06:48 2021 +0200

    Using Kyverno to patch gitops environments
    
    Signed-off-by: Laszlo Fogas <laszlo@laszlo.cloud>

[33mcommit a13e9ed1b19d24386bfd850ea2fa812dbeac5da4[m
Merge: 6e31f050 38a74ad8
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Apr 22 15:58:27 2021 -0700

    Merge pull request #153 from kyverno/fix/correct_sample
    
    update images sample

[33mcommit 38a74ad8e1ef05d8948d8ce9cba3976a2b6705d0[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Apr 22 14:30:54 2021 -0700

    update images sample
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 6e31f05037ddfc8ed296e97cc50e4b499ac43055[m
Merge: 7e1e7424 16bbc112
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Apr 18 18:25:08 2021 -0700

    Merge pull request #151 from kyverno/add_new_policies
    
    add new policies

[33mcommit 16bbc112dd8342d3f2ef37289d05b6c981ffba17[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Apr 18 18:19:36 2021 -0700

    add new policies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 7e1e742462170bc26e923fce94ef57fe69c4bc90[m
Merge: 6d47d897 4f1f4764
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Apr 18 18:02:54 2021 -0700

    Merge pull request #150 from kyverno/update_default_pss
    
    update pod security level default -> baseline

[33mcommit 4f1f4764cceb05d8f16040c5c63dd9efc0647e26[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Apr 18 17:58:58 2021 -0700

    re-render
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 09581549a2441056341243efa94545afbec97d1f[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Apr 18 17:38:28 2021 -0700

    update and re-render
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit c876572d85d4d188cb4d67f3eafda8d49a505832[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Apr 18 16:50:02 2021 -0700

    update pod security level default -> baseline
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 6d47d897da0ceefffe0a3b12f20db4caf2648b2c[m
Merge: a68164a4 0152d7d0
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Apr 17 18:11:35 2021 -0700

    Merge pull request #148 from chipzoller/main
    
    Doc updates

[33mcommit a68164a438b2f8df4458961c677ca6ec1e7e3bf3[m
Merge: 4d413402 439d132e
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Apr 17 18:09:36 2021 -0700

    Merge pull request #144 from kyverno/update_background_scan
    
    Update background scan behavior

[33mcommit 0152d7d0d3adb489f66ed83f2e49dcccf6660a96[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Apr 17 18:53:31 2021 -0400

    add note on wildcard to resource filters
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit a1ae8b8d3ec36123d3a42ab7e640ae25fc3782dc[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Apr 17 18:16:57 2021 -0400

    add updates to patchesJson6902
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 132230ee1120e371fb591ac441863a73e64c3602[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Apr 17 17:55:04 2021 -0400

    add note about CLI support for files from URL
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2bf361c29d454b47defdc2ff25d8a4bef0f882b6[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Apr 17 17:35:38 2021 -0400

    add YAML multi-line info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4d4134024885fd4b6f810c69513c508be8daaa59[m
Merge: ee1092c4 5e7a99d3
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Apr 16 17:59:41 2021 -0700

    Merge pull request #147 from kyverno/enhancement/images_variable
    
    update image variable info

[33mcommit 5e7a99d39e8b24ded2874511f0aab6f9106438ea[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Apr 16 17:51:45 2021 -0700

    update image variable info
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit ee1092c450184b626b4cef283b578b6a2c179a55[m
Merge: 69e66683 aff13c76
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Apr 16 16:54:25 2021 -0700

    Merge pull request #146 from kyverno/update/community_meetings
    
    add contributors meeting

[33mcommit aff13c76a554b2e5427695a8a2c58b936c93281a[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Apr 16 16:41:32 2021 -0700

    add contributors meeting
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 439d132e4dbc16022b5e003feecec0b6110a5786[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Apr 15 19:32:23 2021 -0700

    address the comment
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 066e959e4dc88993dc7ef058c12f61254ae86667[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Apr 15 14:25:41 2021 -0700

    update background scan behavior
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 8ae788623cd464d9d12ba95c6b34a6cf2c9ac5cf[m
Author: vyankatesh <vyankatesh@neualto.com>
Date:   Thu Apr 15 23:41:40 2021 +0530

    fix comment

[33mcommit 09a64ef61d30f1da6c88ae2c2fbc6464da2d159d[m
Author: vyankatesh <vyankatesh@neualto.com>
Date:   Thu Apr 15 22:59:10 2021 +0530

    fix #142

[33mcommit 69e66683a4dbf9f87dcce9f59f97c3f654bb4851[m
Merge: cecec8c7 e76c7569
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Apr 14 15:03:46 2021 -0700

    Merge pull request #140 from chipzoller/main
    
    Implement policy filter

[33mcommit e76c7569bac09009656db75a895eefbec4041be5[m
Merge: 2ba1c5a4 cecec8c7
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Apr 14 09:36:27 2021 -0400

    Merge remote-tracking branch 'upstream/main' into main

[33mcommit cecec8c7c8771465ba20aaafaf3b4d663e9cfc4e[m
Merge: 0dcd78d5 8c519d86
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Apr 13 17:26:56 2021 -0700

    Merge pull request #129 from kyverno/dev
    
    Add any/all documentation

[33mcommit 8c519d86f1ac81392bf0fbe7950979c7b6a568c6[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Apr 13 20:07:14 2021 -0400

    clarify redundancy of multiple `all` statements
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 2ba1c5a4a9b670f4a8247a2aee9ff3fef23531de[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Apr 13 19:18:39 2021 -0400

    Update PSS page
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 544cfc10a994469651515208ce3ffafa27d5f565[m
Author: weru <fromweru@gmail.com>
Date:   Tue Apr 13 20:48:34 2021 +0300

    update sidebar

[33mcommit e8b19b65ae386d27de5a370797bd84ba370795d8[m
Author: weru <fromweru@gmail.com>
Date:   Tue Apr 13 19:28:30 2021 +0300

    restore pod security page

[33mcommit 769928f326a9c413d4bbc379dcbc4df36f4b8761[m
Author: weru <fromweru@gmail.com>
Date:   Tue Apr 13 19:23:50 2021 +0300

    use relative links

[33mcommit 2d09c2bfd56de5e9de4db0f2fc2892d310d27caf[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 22:54:59 2021 +0300

    keep original baseURL

[33mcommit eddb9817af6ba6d371e9f6b4a4b03c3e20418bfd[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 22:53:22 2021 +0300

    use relative links for assets

[33mcommit eebb641b80c80872a7d58d2be4a132ec328e1100[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 22:45:51 2021 +0300

    edit baseURL

[33mcommit 01311c96b14956da97e81759b568646ff3d2e778[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 12 15:42:06 2021 -0400

    exclude Hugo resources folder
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f2e366e745951bd2538256f119625f58864ae34d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 12 15:35:27 2021 -0400

    Remove resource again
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 667f3635937a9d9f0bcce59873e14f0207973d62[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Apr 12 15:34:15 2021 -0400

    remove resources
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit bbaa58f67c79e53d51f3cd50fc23019faba246c4[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 20:29:36 2021 +0300

    regenerate page

[33mcommit c303a94b099ad65edc131a9df800100255cf7a09[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 20:21:23 2021 +0300

    remove unused values from frontmatter

[33mcommit 1f525845a34e3478a925208f89657766d178d25d[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 18:04:34 2021 +0300

    standardize coloring

[33mcommit 84d5933afd96e573347b48da66d6282f847f7cb2[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 16:52:09 2021 +0300

    regenerate page

[33mcommit ac86e87c2f8c69453d83236a5be4b539ecc38b7a[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 16:48:42 2021 +0300

    edit dummy versions

[33mcommit 86d11b18321ab981a3c8ed1cdde23d8b3503afaf[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 16:47:54 2021 +0300

    fix invalid id bug

[33mcommit 62687b1460ec9d3d13fec856e0301d1c08386dd5[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 16:33:42 2021 +0300

    generate policy page

[33mcommit b1f0e205f955cab99c802db7aca5150511f94134[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 16:33:17 2021 +0300

    edit variable call

[33mcommit 052ecc017a5a81a31d18a76ec2300ab7b54c868a[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 16:32:43 2021 +0300

    edit front matter

[33mcommit 431b6161cce83831f6aa93fcc3d77f3d0507214b[m
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 16:30:18 2021 +0300

    add only policy type to frontmatter

[33mcommit 4bc324d6e5ea63b104ceb8af6a63b544ff2da909[m
Merge: 4995db80 0dcd78d5
Author: weru <fromweru@gmail.com>
Date:   Mon Apr 12 15:35:23 2021 +0300

    merge upstream

[33mcommit 0dcd78d53953094353812cf4d1971443b77abcc0[m
Merge: 616089f0 ed112830
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Apr 11 21:26:43 2021 -0700

    Merge pull request #139 from kyverno/render-samples
    
    Render samples

[33mcommit ed11283058a6a659040abc8fdff9da6a8be5cba7[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Apr 11 17:54:06 2021 -0700

    remove dupe and render samples
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 3a9a60fd309c4bbd288f7909313eead120cf5826[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Apr 11 17:53:43 2021 -0700

    remove dupe and render samples
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 4995db80a9fe26994d3b90e4ad1a8b5ad10e797e[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Apr 11 16:31:01 2021 -0400

    lint README
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 1d63d26d9d1e9e2f6cc31901dcbbc1d8eb2c005c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Apr 11 14:17:51 2021 -0400

    correct render README
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6c67995570947da7efc510e7d21f65286dee6699[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Apr 11 14:04:41 2021 -0400

    Remove render binary
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit dcb9fe256b0ab3afb90f300d507ee92151b6988e[m
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 20:52:42 2021 +0300

    minify script

[33mcommit ad3a6f9c8c2b18d0503dbeba48415beb555ce35f[m
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 20:51:01 2021 +0300

    fix array bug

[33mcommit 25f53591dbba3ce0af9ed868b065b3c19b4bbff5[m
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 20:44:45 2021 +0300

    undo unused override

[33mcommit 4ba6f9aefbb23c48eb51a2d3b0db288cb46fe958[m
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 20:42:44 2021 +0300

    edit helpers

[33mcommit 4c62e2942b9ec71913ca55ba9778e52c0a2093ae[m
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 20:42:33 2021 +0300

    rename variable

[33mcommit b8b2b20358d150f2cfd53074761bde26ec375447[m
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 20:42:18 2021 +0300

    move logic into a function file

[33mcommit 364eea44fb518bf58aa287afb75553cb7542a00f[m
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 19:55:56 2021 +0300

    sort applied filters [a~z]

[33mcommit 82f29618cda0ba90f51a8ffa2f8b3b22c8332cc2[m
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 19:50:27 2021 +0300

    sort items alphabetically

[33mcommit 0e87ba34f4fd207a0464571cc6f4102f3ecc4fa7[m
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 19:50:05 2021 +0300

    prefilter policy pages

[33mcommit 2c9384838749bcb58255c69f6022d089f208c30f[m
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 17:23:04 2021 +0300

    hide sections with dummy data

[33mcommit f144fcc771c3b81e6ac426a382e6a9f47d1eff4c[m
Merge: c0f2561f 616089f0
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 17:10:23 2021 +0300

    merge upstream

[33mcommit c0f2561fab5b3dab7bab198938aa715c32db0692[m
Author: weru <fromweru@gmail.com>
Date:   Sun Apr 11 16:32:57 2021 +0300

    change issue topic to policy title

[33mcommit 616089f06bdeb8b0e526107489502f17ad98a6dc[m
Merge: ac5fe56a 16e92c38
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Apr 10 14:14:46 2021 -0700

    Merge pull request #136 from kyverno/samples/render
    
    render sample policies

[33mcommit 16e92c38fd1606e939833f2486ce67c525b3942d[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Apr 10 13:55:44 2021 -0700

    render sample policies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit ac5fe56afb84a9bedac6900b25ff34255189e98f[m
Merge: cb7454b7 32391fbd
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Apr 10 13:54:17 2021 -0700

    Merge pull request #132 from kyverno/add-reviews
    
    update start timestamp

[33mcommit cb7454b721f661e8c741ea6f9d79a461a84b0153[m
Merge: 59d2e6cc a2a3c7f7
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Apr 10 13:53:03 2021 -0700

    Merge pull request #133 from kyverno/feature/restructure_top_level
    
    extract chapters for policy overview, apply, testing, policies

[33mcommit a2a3c7f76c11cb75afbea23443b2349810e82dba[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Apr 10 13:48:15 2021 -0700

    remove newlines
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 65683ad343c80260b16f58c37dff00078414a2f5[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Apr 10 13:47:04 2021 -0700

    fixes based on review
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 2b909c631c3be37530fb784bf115764f4b15af3b[m
Author: weru <fromweru@gmail.com>
Date:   Sat Apr 10 20:09:47 2021 +0300

    fix button overflow

[33mcommit b3fd9811f80b7c6847b3247fc7c1efd9f5760cf2[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Apr 9 13:30:58 2021 -0700

    extract chapters for policy overview, apply, testing, policies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 03c88b4334fbe2b54d04f392de75a2f7ebc4d954[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 9 19:50:32 2021 +0300

    edit link function

[33mcommit d539d6101a78c607f186b2fb54ca409d38defcee[m
Merge: f0040048 59d2e6cc
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 9 18:23:58 2021 +0300

    merge changes

[33mcommit f0040048af5e89d4260ea0353e92fd108aea2789[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 9 17:54:48 2021 +0300

    add comment

[33mcommit c9ed2c4406edd68afc81304f1529a5a00151033a[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 9 17:53:01 2021 +0300

    add inline comments

[33mcommit 398e9d0ab0c1d39c93171ee0681307c92900cde4[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 9 17:43:25 2021 +0300

    edit and document render

[33mcommit df7aabc296c20c78a9c83692e868bf7b6455dbb0[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 9 17:06:46 2021 +0300

    edit github meta links

[33mcommit 2917150a618f7f0d85cacb439037838cba866428[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 9 17:06:25 2021 +0300

    edit policies render template

[33mcommit 4b41040177dc422113d836efd3d41c45c72bc8e5[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 9 17:06:04 2021 +0300

    update translations

[33mcommit b31157a2c8dbfbc57618cd9a1b19a857f542b5db[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 9 17:05:46 2021 +0300

    disable codeblock collapsing

[33mcommit c57fdf497aeb6a461a33d6fd1eb47d9f161db639[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 9 17:05:03 2021 +0300

    hide empty elements

[33mcommit 6f4d3641aa91257d969f0c404c3bcbb069a12b55[m
Author: weru <fromweru@gmail.com>
Date:   Fri Apr 9 17:04:25 2021 +0300

    regenerate policy

[33mcommit 59d2e6cc5a95e04585cecab80aa18fef367d3441[m
Merge: 1d7ad849 d2cfabf7
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Fri Apr 9 18:22:04 2021 +0530

    Merge pull request #128 from vyankyGH/remove_permission
    
    Doc: Remove permission And match and exclude resource

[33mcommit d2cfabf7a11daab795bb1a389eebf42bd6518142[m
Author: vyankatesh <vyankatesh@neualto.com>
Date:   Fri Apr 9 15:14:38 2021 +0530

    update

[33mcommit 32391fbd0bc00b750a7b613465e3552f0193e50c[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Apr 8 17:36:54 2021 -0700

    update start timestamp
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 1d7ad8490b7c8265dd0f7d141a98d22230005f7e[m
Merge: c356617d d05e144e
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Apr 8 17:28:58 2021 -0700

    Merge pull request #131 from kyverno/add-reviews
    
    Add policy reporter episode

[33mcommit d05e144e7c744c27903fc50c331c2665b852440f[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Apr 8 17:24:16 2021 -0700

    add policy reporter episode
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 3634fa88faa3501b181665331829a214f051f883[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Apr 7 11:44:30 2021 -0400

    fix
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 249cd4bb95bad2a6712da640f9e30dcc265279fd[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Apr 7 10:01:08 2021 -0400

    Add any/all documentation
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 885f3a16ae769ab610535430f8e522663566745f[m
Author: vyankatesh <vyankatesh@neualto.com>
Date:   Wed Apr 7 18:04:04 2021 +0530

    fix comments
    
    Signed-off-by: vyankatesh <vyankatesh@neualto.com>

[33mcommit 8f957df173b70318d53102286a5f97c22b8fc194[m
Author: vyankatesh <vyankatesh@neualto.com>
Date:   Wed Apr 7 15:31:05 2021 +0530

    Document: match/exclude to use apiGroup and apiVersion #107
    
    Signed-off-by: vyankatesh <vyankatesh@neualto.com>

[33mcommit 4029bd131fda229e77cd7d607b41304696bb925b[m
Author: vyankatesh <vyankatesh@neualto.com>
Date:   Tue Apr 6 11:10:17 2021 +0530

    remove permission
    
    Signed-off-by: vyankatesh <vyankatesh@neualto.com>

[33mcommit c356617d98fdf0bb0cd252dfc4a4b9af47ff9b4c[m
Merge: 4829ef5f 2f1f9f39
Author: shuting <shutting06@gmail.com>
Date:   Fri Apr 2 10:47:46 2021 -0700

    Merge pull request #126 from kyverno/update_compatible_matrix
    
    Update compatibility matrix

[33mcommit 4829ef5f6cf1b2884688ad53985e05371f633d84[m
Merge: aa984b33 b0171380
Author: shuting <shutting06@gmail.com>
Date:   Fri Apr 2 10:40:59 2021 -0700

    Merge pull request #123 from kyverno/115_image_info_variables
    
    Add variables for image properties

[33mcommit 2f1f9f39062605323a6249fa7674f1faa73fd270[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Fri Apr 2 10:40:39 2021 -0700

    Update compatibility matrix
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit b01713804153d22d84c117d4da608b8aa8f7757f[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Apr 1 13:46:21 2021 -0700

    update statement
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 5b03fdd546661997ae19761b6ffb0d5840662e26[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Apr 1 13:45:46 2021 -0700

    update default image properties
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 0880c3ac5cd6bb78dc80ce40ecb78b1c8673d693[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Wed Mar 31 12:10:23 2021 -0700

    correct code formatting
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit aa984b335066991606b78c5ba7183ee481e88e2e[m
Merge: 40c997b0 28bc5b68
Author: shuting <shutting06@gmail.com>
Date:   Wed Mar 31 08:58:01 2021 -0700

    Merge pull request #122 from kyverno/add_flags
    
    Add flags

[33mcommit 40c997b01aa15e3c5e021a16a16bafecb35dd810[m
Merge: fae0a99a e0fb8d92
Author: shuting <shutting06@gmail.com>
Date:   Wed Mar 31 08:57:39 2021 -0700

    Merge pull request #118 from kyverno/update_uninstall_guidance
    
    Add cleanup steps to remove webook configurations

[33mcommit fae0a99ad4a33a61fe6695683a6e5787a50d85fa[m
Merge: cc421290 1e22a32a
Author: Vyankatesh Kudtarkar <vyankateshkd@gmail.com>
Date:   Wed Mar 31 21:16:05 2021 +0530

    Merge pull request #110 from vyankyGH/feature/test_cmd
    
    Doc: Test Command

[33mcommit 6815486228fa7c97d9e55b200a6b3d1f21d0ac87[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Tue Mar 30 12:36:59 2021 -0700

    - address comments; - add a use case
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 28bc5b68a47efd7720cf6fe00ee814c99a3ad8ab[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Tue Mar 30 11:45:12 2021 -0700

    address comments
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit e0fb8d929a0c30729365b196d864faad1239acab[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Tue Mar 30 11:43:13 2021 -0700

    address comment
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit a5212c17b12f0c3ee2aa93efc13727bb28eba033[m
Author: weru <fromweru@gmail.com>
Date:   Mon Mar 29 19:13:04 2021 +0300

    update helper

[33mcommit e9be323cc3e99723eb05c20864f23e98d6ed6844[m
Author: weru <fromweru@gmail.com>
Date:   Mon Mar 29 19:12:50 2021 +0300

    restyle component

[33mcommit 61b77db6cf921838f48a73a28a4536d137ffca0c[m
Author: weru <fromweru@gmail.com>
Date:   Mon Mar 29 18:18:04 2021 +0300

    add conditional & cleanup

[33mcommit 3079a9b0218d265bb93f0ef09890dd8cdaaae158[m
Author: weru <fromweru@gmail.com>
Date:   Mon Mar 29 17:44:31 2021 +0300

    edit template

[33mcommit 4c1c85f31ed92d21bf22e0ade7e40479e4f807be[m
Author: weru <fromweru@gmail.com>
Date:   Mon Mar 29 17:43:55 2021 +0300

    cleanup & enable shareable queries

[33mcommit 1e22a32a1c24b551d6b7dfe38487f269e7b520b5[m
Author: vyankatesh <vyankatesh@neualto.com>
Date:   Mon Mar 29 12:20:46 2021 +0530

    fix comments
    
    Signed-off-by: vyankatesh <vyankatesh@neualto.com>

[33mcommit 109603f3e1d35386af3329925634a5b5919a9da7[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 22:24:43 2021 +0300

    update

[33mcommit e8febfef423b614588d5ba5b8b5f6074fd3b3040[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 22:24:29 2021 +0300

    restyle components

[33mcommit ea5213b9f044d0e275c710df2f790f569a003364[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 22:22:29 2021 +0300

    update script

[33mcommit 0f198a3262f8550fab8a5665fc5a7ef58d418aa2[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 22:22:07 2021 +0300

    add translations

[33mcommit 6fc50e0964c2b3626b817e22077d3068717edf98[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 22:21:50 2021 +0300

    edit template

[33mcommit d88291fed36d23cb43949c36631444db0fab55b9[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 17:43:38 2021 +0300

    increase spacing

[33mcommit e2d21eed975458130e82f90338327e436a6e2f02[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 17:40:30 2021 +0300

    restyle pre elements

[33mcommit f4af4c0d105937bd94e0acd74c4a655f2c62c96b[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 17:40:17 2021 +0300

    refactor helper

[33mcommit 47d731ff4213e80716829441bfdf8c00e5a974b6[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 16:58:14 2021 +0300

    make icons smaller

[33mcommit e3ccb9f9657d3e01264cbf6889ccbfbd7c8ba3e3[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 16:52:20 2021 +0300

    bump hugo version

[33mcommit 30e85099ec1756e3d1800b375f8870993d7fa52f[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 16:52:03 2021 +0300

    edit file

[33mcommit b46d286e4e4250582ee475b069c49187a17ba008[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 16:51:40 2021 +0300

    edit template

[33mcommit 46f592d6b3379e616124b2b97dae92750ffae917[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 16:51:18 2021 +0300

    restructure components & edit helpers

[33mcommit 56090ea7fb56903960f48eb7bb89f86f0ad262b6[m
Author: weru <fromweru@gmail.com>
Date:   Sun Mar 28 16:50:36 2021 +0300

    restructure config

[33mcommit cc421290a648fe2c4093e8a13e5983a6922f6dcd[m
Merge: 93896dad c8bca3d0
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Mar 26 23:50:31 2021 -0700

    Merge pull request #111 from kyverno/render/update_samples
    
    update samples

[33mcommit c8bca3d09909e90e2ecf9d8dd515690a93b77df6[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Mar 26 17:54:37 2021 -0700

    update policies
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit fb04e97a24389ec1633ff0504bd2e3a45477e334[m
Merge: 79da9356 93896dad
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Mar 26 16:57:42 2021 -0700

    merge main
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 93896dadad7576cdc4527c7406de9777ff556fea[m
Merge: 779e2486 52e6247c
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Mar 26 16:55:44 2021 -0700

    Merge pull request #106 from NoSkillGirl/doc/namespaceSelector_cli
    
    Updated doc for namespace selector in Kyverno CLI

[33mcommit 779e2486666ec6aeb5f7068bba9b5de73d5e84d2[m
Merge: bd9032d4 75ceb42f
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Mar 26 16:55:11 2021 -0700

    Merge pull request #101 from RinkiyaKeDad/not-in-set-fix
    
    docs(preconditions): fixed definition of NotIn for sets

[33mcommit 79da9356eca6294e5a84917411fa51c99c568881[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Mar 26 16:53:26 2021 -0700

    update titles
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit bd9032d4e942e108e07c79c62c014c23281d610b[m
Author: shuting <shutting06@gmail.com>
Date:   Fri Mar 26 13:23:05 2021 -0700

    Update restrict-service-external-ips.md

[33mcommit 046669bfc1435d9a65b2f158ec2ef909ee6f03d5[m
Author: weru <fromweru@gmail.com>
Date:   Fri Mar 26 18:32:55 2021 +0300

    edit config

[33mcommit 2497c8e89c930dbbebb99beefe57a2b32558559b[m
Author: weru <fromweru@gmail.com>
Date:   Fri Mar 26 18:32:21 2021 +0300

    add codeblock styles

[33mcommit 74729c97041978586f61a1e1057f01d3d346faee[m
Author: weru <fromweru@gmail.com>
Date:   Fri Mar 26 18:31:55 2021 +0300

    add and modify helpers

[33mcommit 875f503f84633bd3b2377b70e4a78291dff9ad59[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Mar 25 19:10:59 2021 -0700

    explain "why webhook configurations need to be removed maually"
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 042fa7b8fbec8a85a6a5667f5c504ddc1573cf4b[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Mar 25 18:31:26 2021 -0700

    add variables for image properties
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 7a8cb9b0e6aa60c040f712f2bd23931af4fb757b[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Mar 25 17:39:44 2021 -0700

    Add flags
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 24b248fdf471e7c90f4bec60dc5b60fc15c3d592[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Mar 25 14:39:21 2021 -0700

    update to commands
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit a3a8654d52d237820f46e424e711d66d67c6a180[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Mar 25 14:21:38 2021 -0700

    Add the explanation to uninstall process
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 230133f065b270434043b835a9179aedf89ae84e[m
Author: weru <fromweru@gmail.com>
Date:   Thu Mar 25 21:14:47 2021 +0300

    update todos

[33mcommit 2e465042be6f052f6278f53d7883e0cd531bb13c[m
Author: weru <fromweru@gmail.com>
Date:   Thu Mar 25 21:03:16 2021 +0300

    update template

[33mcommit 6891b6070922af66f4044f5255b324af6906640d[m
Author: weru <fromweru@gmail.com>
Date:   Thu Mar 25 21:02:56 2021 +0300

    enable filter clearing

[33mcommit 45fd73c051497dfc3651cd292a319c0c1a23dea3[m
Author: weru <fromweru@gmail.com>
Date:   Thu Mar 25 21:01:57 2021 +0300

    restyle components

[33mcommit 88eee6b407f48b0b7c2761a13bfe69eeaaf5ab2a[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Tue Mar 23 18:38:39 2021 -0700

    add cleanup steps to remove webook configurations
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 9e81f53075df20503f15e876548f1c5cb5499045[m
Merge: 49f325b7 bcc70410
Author: shuting <shutting06@gmail.com>
Date:   Tue Mar 23 13:30:32 2021 -0700

    Merge pull request #117 from y-taka-23/quote-yes
    
    Quote yes to treat it as a string

[33mcommit bcc70410df6a615355f92401951ff11e94ea05fd[m
Author: Yuto Takahashi <ytaka23dev@gmail.com>
Date:   Wed Mar 24 04:49:08 2021 +0900

    Quote yes to treat it as a string
    
    Signed-off-by: Yuto Takahashi <ytaka23dev@gmail.com>

[33mcommit 49f325b7480c16ed3b29281a7e8093c4a2ae7d39[m
Merge: 755c9900 7bfe348c
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Mar 19 13:26:47 2021 -0700

    Merge pull request #114 from kyverno/add-reviews
    
    Add Cloud Native Islamabad webinar

[33mcommit 7bfe348cb1254b6148b2d78ef542af3d48ca41ed[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Fri Mar 19 13:20:04 2021 -0700

    add Cloud Native Islamabad webinar
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 755c990022980ddeaf2c11b4d247ba41c8001f85[m
Merge: 23c8ae10 0a663923
Author: shuting <shutting06@gmail.com>
Date:   Fri Mar 19 10:45:03 2021 -0700

    Merge pull request #113 from soeirosantos/patch-1
    
    fix shell execution in example

[33mcommit 0a6639236ed2f7214dbbe587a87ec8f47e6fa091[m
Author: Romulo Santos <soeirosantos@gmail.com>
Date:   Fri Mar 19 13:22:57 2021 -0400

    fix shell expansion in example
    
    Signed-off-by: Romulo Santos <soeirosantos@gmail.com>

[33mcommit 23c8ae10e4c18a4dd84cbfb7813714355b9e31bc[m
Merge: e19b22a8 77683b77
Author: shuting <shutting06@gmail.com>
Date:   Thu Mar 18 20:20:45 2021 -0700

    Merge pull request #112 from vyankyGH/bug/sample_policy

[33mcommit 77683b773f5429ce9714e75b673be2eb27c33d43[m
Author: vyankatesh <vyankatesh@neualto.com>
Date:   Fri Mar 19 08:44:39 2021 +0530

    fix sample policy url
    
    Signed-off-by: vyankatesh <vyankatesh@neualto.com>

[33mcommit 4dd6c09029f549960402380f36402204de8c5b9c[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Mar 18 14:46:07 2021 -0700

    update samples
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 19422a2cddf65f3431a8e69be179c23cbab35da4[m
Author: vyankatesh <vyankatesh@neualto.com>
Date:   Tue Mar 16 11:23:15 2021 +0530

    code refactor
    
    Signed-off-by: vyankatesh <vyankatesh@neualto.com>

[33mcommit bd469f8273a744bc44680ec4bb552162f991cd9b[m
Author: vyankatesh <vyankatesh@neualto.com>
Date:   Mon Mar 15 12:43:31 2021 +0530

    documention for test cmd
    
    Signed-off-by: vyankatesh <vyankatesh@neualto.com>

[33mcommit 3789c1ef8fee59165092947c5223eab8b129d74a[m
Author: weru <fromweru@gmail.com>
Date:   Tue Mar 9 16:13:47 2021 +0300

    move policyFilters to config

[33mcommit ef47b302f666d60b16e4ff33acb25e882989480d[m
Author: weru <fromweru@gmail.com>
Date:   Tue Mar 9 16:13:28 2021 +0300

    update template

[33mcommit b711f43666ffcde2bd3c51a736ae85a166471fe6[m
Author: weru <fromweru@gmail.com>
Date:   Tue Mar 9 16:13:05 2021 +0300

    purge poc content file

[33mcommit d3072deb13020ae327c2f84894460ea552450618[m
Author: weru <fromweru@gmail.com>
Date:   Tue Mar 9 16:12:44 2021 +0300

    refactor poc >> policies

[33mcommit 3f900bcd6121ebfe2409bdf833ffbc23bc31bc45[m
Author: weru <fromweru@gmail.com>
Date:   Tue Mar 9 16:11:49 2021 +0300

    add stuff to ignore

[33mcommit bdc89ddf151e1d3fa675e1e657baa4b3657043fa[m
Author: weru <fromweru@gmail.com>
Date:   Tue Mar 9 16:11:31 2021 +0300

    edit styles & helpers

[33mcommit 6cfc0ecd84d8ca73acb4279d034b801df8c320f9[m
Author: weru <fromweru@gmail.com>
Date:   Tue Mar 9 16:10:49 2021 +0300

    edit policy page

[33mcommit 52e6247ce2099ed53fe9c2058a34a8f04d94eb3f[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Thu Mar 4 22:27:08 2021 +0530

    updated
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit ce410a589fd210bc2567ef54596199d114fb20be[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Thu Mar 4 20:20:04 2021 +0530

    added link for namespace selector
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 445085611ce1f3ac8c18665832b232a392872728[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Thu Mar 4 20:06:21 2021 +0530

    added doc for namespace selector in cli
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 75ceb42fae8f5e3e9a7fe53c266a28948534aac0[m
Author: Arsh Sharma <arshsharma461@gmail.com>
Date:   Thu Feb 25 15:09:50 2021 +0530

    docs(preconditions): fixed definition of NotIn for sets
    
    Signed-off-by: Arsh Sharma <arshsharma461@gmail.com>

[33mcommit e19b22a883d28a229adc3b50d993eb79d83ac10b[m
Merge: 968c50ba 20717911
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Feb 18 17:31:31 2021 -0800

    Merge pull request #100 from kyverno/dev
    
    add new blog

[33mcommit 20717911a0db39d0b4b63b1aa5e75842bc6c466a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Feb 18 20:27:47 2021 -0500

    add new blog
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 968c50ba0a8777f4bf6c5e188e5495376113e4cf[m
Merge: 65701f13 e3123f6c
Author: shuting <shutting06@gmail.com>
Date:   Thu Feb 18 11:59:48 2021 -0800

    Merge pull request #99 from kyverno/add_reviews
    
    Add Rawkode review

[33mcommit e3123f6c2539c3b60ecbed053a319c9703555d90[m
Author: Shuting Zhao <shutting06@gmail.com>
Date:   Thu Feb 18 11:28:10 2021 -0800

    add Rawkode review
    
    Signed-off-by: Shuting Zhao <shutting06@gmail.com>

[33mcommit 1c09b270a1bdafd17927c71049d638ba6a21f143[m
Author: weru <fromweru@gmail.com>
Date:   Wed Feb 17 04:24:56 2021 +0300

    edit localstorage key

[33mcommit 6f1f832cbcc8fc54df75d86aa0a8ce734836e1e0[m
Author: weru <fromweru@gmail.com>
Date:   Wed Feb 17 04:19:53 2021 +0300

    refactor filtering helpers

[33mcommit 83a9e2f3d7a4e33a2bccc91eeb3d772c1a9679cf[m
Author: weru <fromweru@gmail.com>
Date:   Tue Feb 16 23:26:34 2021 +0300

    edit page

[33mcommit e1690e52d626622edd3bf31ca2bc4f39101ff73c[m
Author: weru <fromweru@gmail.com>
Date:   Tue Feb 16 23:11:25 2021 +0300

    add dummy values to index

[33mcommit e03718136e9f49e2be28cc2a8658120343cfaffb[m
Author: weru <fromweru@gmail.com>
Date:   Tue Feb 16 23:11:03 2021 +0300

    edit template

[33mcommit df85c5519192c2adb0d80ffc50ddabecc60e4694[m
Author: weru <fromweru@gmail.com>
Date:   Tue Feb 16 18:58:51 2021 +0300

    update categories

[33mcommit 9bd326c533699d2090da646ce03eb9b0a9244fa9[m
Author: weru <fromweru@gmail.com>
Date:   Mon Feb 15 19:39:02 2021 +0300

    edit template

[33mcommit ce95f5379652b45cc0eef7c40971f545fabe7079[m
Author: weru <fromweru@gmail.com>
Date:   Mon Feb 15 19:38:18 2021 +0300

    edit frontmatter

[33mcommit 2cf08b6c9edb25014a616643f3c299d21d1d4a02[m
Author: weru <fromweru@gmail.com>
Date:   Mon Feb 15 19:37:58 2021 +0300

    define policy types in config

[33mcommit 75e59f987c07443ca7345d62eae0a714f774f2da[m
Author: weru <fromweru@gmail.com>
Date:   Mon Feb 15 19:30:02 2021 +0300

    bump hugo v 0.74.3 >> 0.80.0

[33mcommit 3d464f04523daba6778a2c49aa225f5d204420c0[m
Author: weru <fromweru@gmail.com>
Date:   Mon Feb 15 19:24:42 2021 +0300

    edit baseURL

[33mcommit 6bb3bb894d0f80897392ff21b0a2f2a9476bf8f1[m
Author: weru <fromweru@gmail.com>
Date:   Mon Feb 15 19:20:42 2021 +0300

    prohibit crawlers from indexing pages

[33mcommit e7a3600f25a08ac61229d43c732594511f03a14e[m
Author: weru <fromweru@gmail.com>
Date:   Mon Feb 15 18:57:35 2021 +0300

    ignore node_modules

[33mcommit 8c571c4e1c9c17512033fa7d51e433e4ab37ffff[m
Author: weru <fromweru@gmail.com>
Date:   Mon Feb 15 18:56:56 2021 +0300

    add poc

[33mcommit abb20b41235859efc06515fcbbb0b69b3917bba6[m
Author: weru <fromweru@gmail.com>
Date:   Mon Feb 15 18:55:24 2021 +0300

    regenerate page

[33mcommit 9eb4d56c63c779efccf18a1877452674594b129a[m
Author: weru <fromweru@gmail.com>
Date:   Mon Feb 15 18:54:42 2021 +0300

    add category & rules to frontmatter

[33mcommit 65701f13518244324a0b75404f1b7e919ff27466[m
Merge: fd78ea8d b4144fcf
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Feb 13 17:56:42 2021 -0800

    Merge pull request #93 from kyverno/dev
    
    Minor fixes and updates

[33mcommit fd78ea8d14aa63925dd39c8133ae8352d28afe72[m
Merge: 627aa933 6f2f3367
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Feb 13 17:54:58 2021 -0800

    Merge pull request #95 from kyverno/namespace-selector
    
    add namespaceSelector

[33mcommit 627aa9334ab0da6953f11e9b04c4e9f17b8a3351[m
Merge: a2463259 63caa8ec
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Feb 13 17:54:38 2021 -0800

    Merge pull request #96 from RinkiyaKeDad/in-set
    
    docs(preconditions): documented set operations for In and NotIn

[33mcommit a246325964e4c29419225fb915fa4af5b57ff25b[m
Merge: 3b716a3e 76e39c97
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Feb 13 17:54:16 2021 -0800

    Merge pull request #90 from NoSkillGirl/doc/policyReport
    
    Document - policy report

[33mcommit 3b716a3ef506bb0d13fd69e46c5265b984105966[m
Merge: a129be14 66e61168
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Feb 13 17:53:28 2021 -0800

    Merge pull request #98 from kyverno/add_contributor_resources
    
    add contributor resources

[33mcommit 66e61168c574fc5fed8a169b78f49dee9f7e167a[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Feb 13 17:46:08 2021 -0800

    add contributor resources
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit b4144fcf64b3f13d0eb40245280358f2c82b8bfb[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 12 19:26:02 2021 -0500

    add and operator to validate table
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 92f5b49fc89ee4c8932790e17fc5d54afd413abe[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 12 18:06:11 2021 -0500

    add note about EKS troubleshooting and hostNetwork
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 3e4a905338900b779514c02b6a5bb54d231795ce[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 12 17:54:29 2021 -0500

    note to disable PSS policies
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6ce2cc6042558fb09494b0ce4233c15e23849ef4[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Feb 12 16:58:06 2021 -0500

    update statement about mutate removal failures
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 63caa8ecf2d5fed82925b8ba8c0ba0a2911a646e[m
Author: Arsh Sharma <arshsharma461@gmail.com>
Date:   Fri Feb 12 22:28:46 2021 +0530

    docs(preconditions): minor fixes
    
    Signed-off-by: Arsh Sharma <arshsharma461@gmail.com>

[33mcommit 76e39c97a749f314d3623ce37397891de392e956[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Fri Feb 12 17:29:42 2021 +0530

    updated
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit c87a3f0f10c78beec144964292c083df4b64dab7[m
Author: Arsh Sharma <arshsharma461@gmail.com>
Date:   Fri Feb 12 13:50:44 2021 +0530

    docs(preconditions): documented set operations for In and NotIn
    
    Signed-off-by: Arsh Sharma <arshsharma461@gmail.com>

[33mcommit 6f2f33671610c22c090dad174ce85c5c0127c23a[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Feb 11 01:19:17 2021 -0800

    add namespaceSelector
    
    ..to list of match / exclude elements
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 453eb4800f6d8b1b3a0fb7f720d5d83b0f7c6aaf[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Feb 10 10:50:22 2021 -0500

    add initial styling and conventions
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 233bdd70b8ed91fea06f9db03f1feffd677f7640[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Feb 10 10:10:17 2021 -0500

    minor formatting and linting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 0c97f4f0ca9eaaec8ad5071dbafd9464c901b702[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Feb 10 09:37:16 2021 -0500

    Add Helm 1.3.2 note about PSS install
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit f66eb3dfe0332b1d1ffefd365d304e18b2c5ebc8[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Wed Feb 10 15:29:30 2021 +0530

    added live cluster instruction
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 6a3b401b87fcc58b139c9ea4ded8484dcd4717e1[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Wed Feb 10 12:35:44 2021 +0530

    yaml syntax
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit a129be14a6716d381a23e17fc8d69b7f820744e9[m
Merge: 5961c0dd 43a5012e
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Feb 9 12:19:21 2021 -0800

    Merge pull request #91 from NoSkillGirl/doc/namespaceSelector
    
    added namespace selector example

[33mcommit 43a5012e0865fb9a147664d6920fbe304dfa3a63[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Feb 9 12:03:49 2021 -0800

    update example
    
    update "Match a Deployment deployed in a namespace having a specific label" example
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 5961c0dd17fb24f6a1bedab8fe6dc4912272d310[m
Merge: 280c0756 14139bc7
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Feb 9 11:50:08 2021 -0800

    Merge pull request #86 from kyverno/81_docs_for_apicalls
    
    docs for APICall

[33mcommit 8ddc18de16814b512044a967340ca45f437b47c5[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Tue Feb 9 20:39:43 2021 +0530

    updated
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit e201f2a63fac7a848fc8f0ba9a1e0f08dd0af9eb[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Tue Feb 9 20:38:48 2021 +0530

    updated table
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit ecffdd4a688b05a8d81d937f1f39047e7339d13d[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Tue Feb 9 20:30:10 2021 +0530

    updated according to comments
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 5941e660e38cd78057bd43796f3672a8fb8b2083[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Tue Feb 9 15:33:18 2021 +0530

    added namespace selector example
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 6e9f3687a7e4bf69944e71d1987e858bf433746d[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Tue Dec 1 18:44:26 2020 +0530

    added yaml tag
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit c7bb6705c371a0bb384cf80d1c2958fe3cf1a7c9[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Tue Dec 1 18:34:42 2020 +0530

    new lines added
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit ea40247d1b97623327cf81c51ee85da2e3dd1251[m
Author: Pooja Singh <36136335+NoSkillGirl@users.noreply.github.com>
Date:   Tue Dec 1 18:38:59 2020 +0530

    Update content/en/docs/Kyverno CLI/_index.md
    
    Co-authored-by: Tim Bannister <tim@scalefactory.com>
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 2a7107e400fa0a0abb24d3ec980db0e63c75811a[m
Author: Pooja Singh <36136335+NoSkillGirl@users.noreply.github.com>
Date:   Tue Dec 1 18:34:01 2020 +0530

    Update content/en/docs/Kyverno CLI/_index.md
    
    Co-authored-by: Tim Bannister <tim@scalefactory.com>
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 0eaa4c671075aafcacf5b0a09d45e1cb618eabc8[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Thu Nov 19 17:15:11 2020 +0530

    updated readme
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 7ba914da04b1cdf854e1f9b0b592bb7cccd5e367[m
Author: NoSkillGirl <singhpooja240393@gmail.com>
Date:   Tue Nov 3 20:39:17 2020 +0530

    added documentation for CLI policy report
    
    Signed-off-by: NoSkillGirl <singhpooja240393@gmail.com>

[33mcommit 280c0756806a48ea9a49a37eb7755e9e0eb1b646[m
Merge: 3ada3d6c 5189e0d8
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Feb 8 16:51:48 2021 -0800

    Merge pull request #88 from kyverno/feature/update_nirmata_link
    
    update Nirmata URL

[33mcommit 5189e0d8e8f5e100891cc0084b8d63189fa8f080[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Feb 8 16:48:13 2021 -0800

    update Nirmata URL
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 14139bc74257de09ad75cc174947e3c124e303c2[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Feb 8 16:15:09 2021 -0800

    hyphenate per-rule
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit c6bf91976246a66e686cc7a10b48848d45ce6df5[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Feb 8 16:04:10 2021 -0800

    ...mo fixes from comments
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit a304c48d157c199989644ffa3aa49fba0888cf40[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Feb 8 15:35:52 2021 -0800

    fixes from comments
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit f0b38805f0872132c91feb66758aa33ef65f6438[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Feb 8 15:33:56 2021 -0800

    fix typos
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 3ada3d6c01458f7a449afddac22d470dc834e910[m
Merge: 60dab931 082628b9
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Feb 8 15:18:37 2021 -0800

    Merge pull request #85 from kyverno/dev
    
    Updates

[33mcommit c6778c155e4fcf784ebda7a98f0b0e68fdb43204[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Feb 7 18:11:23 2021 -0800

    add new file
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 27783730661d404f30e15880dc52f6cb4a2e5292[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Feb 7 18:01:59 2021 -0800

    docs for APICall
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 082628b94e594c3082ce475894027c112e92cbba[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Feb 6 12:02:44 2021 -0500

    updates to Render
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 7017dac0b4ef7409fc1d40289f9153f81b4c6bd3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Feb 6 10:49:18 2021 -0500

    add GKE troubleshooting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit a3225889a39f90964833f5762b43a2bb1863e1ef[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Feb 6 10:38:26 2021 -0500

    minor mods to helm info
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 60dab931e27ab7469c44453ec244371bce6bfab1[m
Merge: 02d8acb3 1aebdd54
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Feb 2 15:33:05 2021 -0800

    Merge pull request #80 from kyverno/dev
    
    Re-swizzle pages

[33mcommit 1aebdd54654238bcf7d9479147cc94db72f54f5a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Feb 2 18:10:46 2021 -0500

    move Community to top navbar
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit ab2c011cff492cbc4d30eb038ec82b088bc7700a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Feb 2 18:09:43 2021 -0500

    remove roadmap
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 51853a58e84205b2be39d1f8d72b51705bf0c847[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Feb 2 18:02:15 2021 -0500

    move Troubleshooting to its own top level
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 02d8acb32fbbd4f816d3c455b13531fd760e35d9[m
Merge: 4276afb1 a3c12f58
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Feb 2 14:30:52 2021 -0800

    Merge pull request #77 from kyverno/dev
    
    Updates

[33mcommit a3c12f58f0b45d7b8e48a4238d4ed04f42b52286[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Feb 1 18:10:50 2021 -0500

    add examples illustrating policy reports
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 8433ec3e55ec59d28bad0b7eecbcada04c68253c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Feb 1 16:19:54 2021 -0500

    more policy report clarifications
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6b31d59c25d12157922d88e5a653ad913962f8a3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Feb 1 15:40:44 2021 -0500

    further report update
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4d16f8f7cf275ae1d099b8366308a95fdb78a634[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Feb 1 13:40:11 2021 -0500

    clarify policy report behaviors
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b5f7d65b6c433e15f1381cb789570cf911020b6d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Feb 1 11:47:16 2021 -0500

    add kustomize note to PSS page
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 9a85a78a6cd449336edd8675d694369e415846cd[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Feb 1 11:38:52 2021 -0500

    add note to CLI about external kustomize
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 906fbfc64ed43c4e1f2c65c466766646bf49cdbd[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Feb 1 09:39:39 2021 -0500

    minor formatting, cleanup
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 42667f282161d1d80481160c1e61e08d3d69ca4c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jan 30 09:57:36 2021 -0500

    add troubleshooting page
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 89e0ce19110256ea56e35d82119871a7cfe25b5d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jan 30 08:44:09 2021 -0500

    add blogs
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit a6f255ee507f4119d6952cba49f0ac716fa24746[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jan 30 08:19:08 2021 -0500

    update note on custom CA process
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 4276afb1b18806a5a2c8d04c6279089d309c56d2[m
Merge: 4b8ead93 dd1cc756
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jan 26 14:51:31 2021 -0800

    Merge pull request #73 from kyverno/dev
    
    Add compat matrix; add JMESPath nesting

[33mcommit 4b8ead932d1b2fa644f0ae61d2e54123b0247834[m
Merge: 60809fff 154604d1
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Jan 26 14:50:50 2021 -0800

    Merge pull request #74 from kyverno/bugfix/add_kustomize_details
    
    add kustomize links and details

[33mcommit dd1cc75688f00c5b049753eb36407d1312bd047b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Jan 26 13:47:06 2021 -0500

    change language
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 154604d1bef6298c9780531333f6f3ac31da99ea[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jan 22 00:19:07 2021 -0800

    add kustomize links and details
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit 198983e072a602e8ffc65c20adadeeef11c7f0d2[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jan 21 20:40:53 2021 -0500

    add JMESPath nesting
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 3c359dfb70255e12fd776f003a423eacb5167b61[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jan 21 20:09:14 2021 -0500

    add Kyverno compat matrix
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 60809fff680680b002de2dd1d899f8bdc37541c9[m
Merge: 5118e63e 101fbe62
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jan 21 09:08:33 2021 -0800

    Merge pull request #72 from kyverno/dev
    
    add info on forward slash escape char

[33mcommit 101fbe620b1b1f66ed5b400dae0b4be620ba5a1f[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Jan 21 07:59:30 2021 -0500

    clarify json patch escape
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 61120070958ebae2fa59c85c2a658789e1887346[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jan 20 22:07:52 2021 -0500

    add info on forward slash escape char
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 5118e63e628669e23bb3fcf9e7b9a10a51a8034d[m
Merge: b779c714 2425e21d
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Jan 17 23:00:17 2021 -0800

    Merge pull request #71 from kyverno/mutate-updates
    
    Mutate updates

[33mcommit 2425e21d1a055f2b71a403484039c9830d2dd9ae[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jan 16 18:46:09 2021 -0500

    expand patchesJson6902 section
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit 6b16642482a50c7d73bba3b937edeb6db45eb216[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Jan 16 18:41:58 2021 -0500

    update flag name
    
    Signed-off-by: Chip Zoller <chipzoller@gmail.com>

[33mcommit b779c7145f5f3af0764d9a4ac0f889389c0f4c59[m
Merge: bdeac5bf c1b79dbd
Author: shuting <shutting06@gmail.com>
Date:   Thu Jan 14 16:45:36 2021 -0800

    Merge pull request #70 from kyverno/add-multi-tenancy-link
    
    add multi-tenancy presentation

[33mcommit c1b79dbdce1a63bff5c0c9d69dc7e1e32dd19678[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jan 14 14:57:54 2021 -0800

    add multi-tenancy presentation
    
    Signed-off-by: Jim Bugwadia <jim@nirmata.com>

[33mcommit bdeac5bfdf840224c75df26b58b3f4c574b66281[m
Merge: 560bee1d d4ce0914
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jan 8 08:04:06 2021 -0800

    Merge pull request #68 from kyverno/bugfix/57_update_CRD_section
    
    Bugfix/57 update crd section

[33mcommit d4ce09141781c7002aa0ab2fd66612ac0330045d[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jan 8 07:39:57 2021 -0800

    fixes

[33mcommit 560bee1d0ae0446a3fdc3e6d6294929a0c365cf5[m
Merge: feaaf9d4 adadd961
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jan 8 07:36:56 2021 -0800

    Merge pull request #67 from kyverno/update/add-post
    
    add CNCF post

[33mcommit feaaf9d43277f5410a3ef95ea7b6680be35ee58f[m
Merge: 7f725c32 c0a66a39
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jan 8 07:36:47 2021 -0800

    Merge pull request #69 from kyverno/feature/32_policy_reports
    
    Feature/32 policy reports

[33mcommit c0a66a39cd1307a843614b6741652a65a36ced2d[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jan 7 22:28:32 2021 -0800

    fixes

[33mcommit 3b9cba66a0087f76da898fb6d0e25dc80dc21412[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jan 7 22:21:51 2021 -0800

    update policy violations to policy reports

[33mcommit e9ca6d26e773ba948f43540999e42b4e1c0a4573[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jan 7 22:12:21 2021 -0800

    update policy violations to policy reports

[33mcommit 2aa8a7b35299d0301ec2f5be58c2a5d6172ca74d[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jan 7 21:42:21 2021 -0800

    update CRD section

[33mcommit abbe42b6fb249d3593b770bc43b9fe402067f7ad[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jan 7 21:41:59 2021 -0800

    update CRD section

[33mcommit adadd961a58ec19d670bf38bbe510cb2d5f00b18[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Jan 7 19:08:51 2021 -0800

    Update _index.md

[33mcommit 7f725c3274047164c8d770224717b3c8450e6969[m
Merge: 8329623d a91566b4
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Jan 6 07:41:37 2021 -0800

    Merge pull request #65 from kyverno/dev
    
    manual install fixes

[33mcommit a91566b40a56816f87d0cb22ad164fb53f246343[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jan 6 10:08:14 2021 -0500

    clean out deleted policies' MD

[33mcommit 6a8a7fceba5e4bf797f59e9f4c4417c86ed5d8a6[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Jan 6 09:25:29 2021 -0500

    manual install fixes

[33mcommit 8329623d8751b1fd4e227a54ea6fb7e14ccb4b0e[m
Merge: 28bc6efe b31250bf
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jan 4 10:10:06 2021 -0800

    Merge pull request #62 from kyverno/feature/simplify_install_instructions
    
    Update _index.md

[33mcommit 28bc6efeb79357194e8e3c209c82237e397495eb[m
Merge: 062bb066 6b9168e1
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jan 4 10:09:52 2021 -0800

    Merge pull request #61 from kyverno/updates
    
    minor clean-up

[33mcommit b31250bf7a7440ad7d80fc7f28ed6fc4e917f27a[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Jan 4 09:56:47 2021 -0800

    Update _index.md

[33mcommit 6b9168e1d9ebe43fa2834e82df93f0d783e1549c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Jan 3 10:17:34 2021 -0500

    minor clean-up

[33mcommit 062bb0663c1afa59542a37ec1d7d330f63fe908d[m
Merge: 8e7dbffb 9a0d72f8
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Jan 2 16:11:36 2021 -0800

    Merge pull request #60 from kyverno/feature/update_policies
    
    feature/update policies

[33mcommit 9a0d72f866c63a2302e6f62390102488d8847b70[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Jan 2 02:10:01 2021 -0800

    fix titles

[33mcommit ea1a4858969d221d489971a50ffe48185141b923[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Jan 2 02:04:37 2021 -0800

    add policies

[33mcommit fa7e171d9d8131d4f42ae6775169a5d1f3dfa253[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Jan 2 02:03:25 2021 -0800

    fix title & sort and regen policies

[33mcommit 8e7dbffbc1d999e8aaf601e3c9e16b2a701e0785[m
Merge: f1b97dd0 d0d4a610
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Jan 1 14:13:26 2021 -0800

    Merge pull request #58 from kyverno/dev
    
    fix misspelling

[33mcommit d0d4a61029dc1828440e46a816f38fd940f0cf75[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Dec 31 08:59:23 2020 -0500

    fix misspelling

[33mcommit f1b97dd0a425a85269ebd33419731a22ae24dc93[m
Merge: 938fc270 3fbb353d
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Dec 30 07:43:15 2020 -0800

    Merge pull request #56 from kyverno/feature/update_sample_policies
    
    update sample policies

[33mcommit 938fc2702b0da94a4db997f6cfee65b4cfdb04a8[m
Merge: 61ab0c22 63304917
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Dec 30 07:28:48 2020 -0800

    Merge pull request #54 from kyverno/dev
    
    Updates

[33mcommit 633049176e8ab18b99f7a2628d7fc2503c5f71f1[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 30 10:22:43 2020 -0500

    add deletion note to generate

[33mcommit 5df247963252f1a9281e59293273939a53955e42[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 30 10:18:28 2020 -0500

    add note about deletion of synced generated resources

[33mcommit d730f523b7969d46d0007d6423c8e71a86c16bd0[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 30 10:12:37 2020 -0500

    update resources

[33mcommit ca0c2c2a9e561a23006a15c60cecebe0998825c6[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 30 09:37:46 2020 -0500

    clarifications

[33mcommit 3fbb353dc3dafd188b7515da9d5a175ae2e8c4c8[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Dec 30 01:09:23 2020 -0800

    update text

[33mcommit 8ebd091af2e6475a841c0559b3a735388276e19a[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Dec 30 01:01:44 2020 -0800

    update policies text

[33mcommit 90d09f697be05171d49a775913d93269599e478b[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Dec 30 00:59:48 2020 -0800

    fix typo

[33mcommit 647553b357143dd3dcc5f7faf1c4c42d43742e5c[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Dec 30 00:48:56 2020 -0800

    update sample policies

[33mcommit 61ab0c2203b5544b6326f9c71aeea0965fba2f46[m
Merge: e129967b a6d75713
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Dec 29 17:12:31 2020 -0800

    Merge pull request #53 from kyverno/feature/render_sample_policies
    
    render sample policies

[33mcommit 5c47d5d1046404d6b42d54763c2db49a7a12562c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Dec 29 11:20:52 2020 -0500

    fix notes and add when to use deny rules

[33mcommit 7b8925e758b1bce9e7aee108a9c5d915511b53a3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Dec 29 11:20:24 2020 -0500

    add pattern vs deny tip

[33mcommit e2b12b4ef940573ca1309f985d8a8d8be6cf1434[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Dec 29 11:19:55 2020 -0500

    add section on binding generation

[33mcommit e129967b5aed24eb2bfcd8f4d91f9b7bcc195651[m
Merge: 3a7336cb 3a3806ec
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Dec 28 07:39:11 2020 -0800

    Merge pull request #52 from kyverno/dev
    
    Updates to dev

[33mcommit a6d757132860db733e09b627bd06cf7c74ce5218[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Dec 27 23:00:59 2020 -0800

    add policy section intro

[33mcommit ab0d6cc9e0a86f54ff9145de4b1cff629559a75b[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Dec 27 22:40:01 2020 -0800

    add pod-security and sample policies

[33mcommit 6ac0c57b2c56d9985e40a33addb83453bfc00bd8[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Dec 27 22:38:54 2020 -0800

    add policies

[33mcommit 6905cb7c3369227b789e3e1e4022bbcbfcfd66e4[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Dec 27 22:36:21 2020 -0800

    add utility to render markdown from policy YAMLs in a Git repo

[33mcommit 3a3806ec7fa0abb91cc0cb51363f1fc7ffd6c21e[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Dec 18 08:21:19 2020 -0500

    restore background and generate pages

[33mcommit 2f2e924db15387d1ae63a3d2acd207362fc7b495[m
Merge: 57eb9ac1 3a7336cb
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Dec 18 08:11:25 2020 -0500

    Merge branch 'main' into dev

[33mcommit 57eb9ac1a3156066b2fc56aacffe68ba3a77f9c7[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Dec 13 09:08:45 2020 -0500

    add tips page

[33mcommit 84188b8ccb292b2861cee6dc180a67c3083752f4[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Dec 12 09:50:28 2020 -0500

    add more AdmissionReview objects to variables

[33mcommit 312ce1bdedd19046a17344e3f54f2e3431b76968[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Dec 12 09:40:46 2020 -0500

    clarify wildcard support in match and exclude

[33mcommit d9df85cfa6a120354f3c61c37fd87e47cc39da38[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Dec 12 09:37:00 2020 -0500

    updates for 1.3.0

[33mcommit 77418048a05867cdf056c0fb0a2938e0bb852e33[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Dec 12 09:30:39 2020 -0500

    clarify, clean

[33mcommit 401a6e95124f855dd94905b7d59c330908471af7[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Dec 12 09:02:35 2020 -0500

    updates

[33mcommit 3a7336cbb4389ce5bffb14cd06d3b99e9689262a[m
Merge: 36a71c49 ebb8aa61
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Dec 9 11:40:12 2020 -0800

    Merge pull request #50 from kyverno/dev
    
    Updates

[33mcommit ebb8aa61a256c142731fe641225d1c4b3cfb594b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Dec 9 13:56:17 2020 -0500

    fix mutate deprecation note

[33mcommit 36a71c4921c30f00337a69befc25b175276939b3[m
Merge: a31c869b 96757e5a
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Dec 7 08:18:52 2020 -0800

    Merge pull request #30 from kyverno/bugfix/28_gen_existing_resources
    
    update generate docs

[33mcommit a31c869b8402d5306a7ae621b7504408dd099358[m
Merge: eae9f971 1d40359d
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Dec 7 08:18:16 2020 -0800

    Merge pull request #51 from kyverno/feature/further_clarify_background_mode
    
    further clarify background scans

[33mcommit 96757e5acd54fcbb20c091a5b2933763534e7309[m
Merge: 11e67a10 eae9f971
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Dec 7 08:17:53 2020 -0800

    fix conflicts

[33mcommit 1d40359d354a06e69797a94a1adc764a97600491[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Dec 7 08:07:12 2020 -0800

    fix typo and clarify scan at start

[33mcommit 2b317a51390af2d75c0edf25149fc3fdc3f0b36a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Dec 7 09:37:15 2020 -0500

    update autogen

[33mcommit 1cb523e50e2210b226441ee7912a32fe01d54c36[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Dec 5 15:15:08 2020 -0800

    further clarify background scans

[33mcommit 21ebde94d0e6e0cdd0e9c7b515a1277ca65b5d7e[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Dec 4 12:35:58 2020 -0500

    rework mutate

[33mcommit eb116759136608478cf62dd555d68a27f0c891dc[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Dec 4 10:10:59 2020 -0500

    make quick start quicker

[33mcommit 12eeff231db59a48e80e0b5e2cd183c42f3c8458[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Dec 4 09:45:25 2020 -0500

    minor tweak

[33mcommit e66d1cc7aa852f9e26ad1771592a89e1c660c19f[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Dec 4 09:45:01 2020 -0500

    capitalizations

[33mcommit 9684ca30c23e257c7bd221f8e9f70475bfcfe685[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Dec 4 09:44:19 2020 -0500

    add upgrade and uninstall process

[33mcommit 64f2e30b0b4b4b420f9002939ea2d7f53b5bf8e1[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Dec 1 14:24:02 2020 -0500

    re-write match-updates

[33mcommit e41fbc31279ac525d4165de45a2cdda1b1756131[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Dec 1 14:23:21 2020 -0500

    misc updates

[33mcommit eae9f97106181219ee65851ad54c13e30fb5f8ea[m
Merge: 1e174a17 33ee26cd
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Nov 30 07:18:15 2020 -0800

    Merge pull request #49 from kyverno/dev
    
    add deprecation notice; minor formatting

[33mcommit 33ee26cded2cb52d83f3d6e52ea750f763ab442d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Nov 30 09:09:02 2020 -0500

    add deprecation notice; minor formatting

[33mcommit 1e174a175665a49ceb31fb1c837e00a7fc954160[m
Merge: dd59feb6 2e34cd28
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 28 18:58:31 2020 -0800

    Merge pull request #47 from kyverno/dev
    
    Updates

[33mcommit 2e34cd2812d6dff0e1e0a24d247afb0647cda591[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 28 18:57:28 2020 -0800

    add reference to HA issue

[33mcommit 4df3061d9bc0edd55ae05298a18197dde23ca8c9[m
Merge: eee08d3a dd59feb6
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 28 18:50:44 2020 -0800

    merge main

[33mcommit dd59feb69b123f30eecac7ae2761a24dfb0fea53[m
Merge: a64be36e 992dd94a
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 28 18:43:26 2020 -0800

    Merge pull request #42 from sftim/20201127_tidy_markdown
    
    Tidy monospaced blocks and inlines

[33mcommit a64be36ec0f26672e44b8996aa490594d6c6431d[m
Merge: 087e4c48 56f52734
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 28 18:42:37 2020 -0800

    Merge pull request #41 from sftim/20201127_tidy_meeting_notes_hyperlink
    
    Tidy meeting notes hyperlink

[33mcommit 087e4c484645251790da8d7751c917123a116460[m
Merge: b05d982b 7c61881b
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 28 18:41:48 2020 -0800

    Merge pull request #40 from sftim/20201127_remove_deprecated_local_actions
    
    Remove already-deprecated local actions

[33mcommit b05d982b74463b540784cd1d42a87d494a7df232[m
Merge: 43f80cfd c91b8654
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 28 18:40:42 2020 -0800

    Merge pull request #43 from sftim/20201127_fix_local_preview_container_image_name
    
    Fix image name for local previewing

[33mcommit 43f80cfd4a5c405c0366b2df5df668f947bd294c[m
Merge: 3480d9fe 47184d85
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 28 18:39:41 2020 -0800

    Merge pull request #44 from sftim/20201127_use_youtube_shortcode_for_videos
    
    Use YouTube shortcode for videos

[33mcommit 3480d9fefa7f5d290c4edff286dfcea33f3c7d48[m
Merge: b114ff5c 6629a27d
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 28 18:38:30 2020 -0800

    Merge pull request #45 from sftim/20201127_tweak_readme
    
    Add README details about local previewing

[33mcommit b114ff5cd7629efb9c888c61d07c3c0f282f78b5[m
Merge: 020f8e98 08e15ceb
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 28 18:37:34 2020 -0800

    Merge pull request #46 from sftim/20201128_use_docsy_callouts
    
    Use Docsy callouts for notes

[33mcommit 11e67a10ee1420169ab38907e2eaf82368a8090d[m
Merge: d3a73a48 020f8e98
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 28 18:35:14 2020 -0800

    merge main

[33mcommit eee08d3a552a9825a85ef0b7fdb60b64465bbf8a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Nov 28 09:22:57 2020 -0500

    installation updates

[33mcommit e48c55fc20334b0b7a7f7afd25ca11bad5cac30f[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Nov 28 08:56:03 2020 -0500

    remove relrefs

[33mcommit 08e15cebe1e440769764031da779445e0eeabf45[m
Author: Tim Bannister <tim@scalefactory.com>
Date:   Sat Nov 28 13:52:12 2020 +0000

    Use Docsy callouts for notes

[33mcommit 56f52734dd92e232b15219f3058560b170f0ec22[m
Author: Tim Bannister <tim@scalefactory.com>
Date:   Fri Nov 27 19:47:05 2020 +0000

    Tidy meeting notes hyperlink
    
    Signed-off-by: Tim Bannister <tim@scalefactory.com>

[33mcommit 7c61881bce8e0d010ec34b0287c5b6e86a62a235[m
Author: Tim Bannister <tim@scalefactory.com>
Date:   Fri Nov 27 19:45:11 2020 +0000

    Remove already-deprecated local actions
    
    As this deprecation happened before the code was live, it's fair to
    assume that people aren't using the deprecated targets. Remove them.

[33mcommit 992dd94ab606053a9a14db76afae2fe90c1d6221[m
Author: Tim Bannister <tim@scalefactory.com>
Date:   Fri Nov 27 19:40:43 2020 +0000

    Tidy monospaced blocks and inlines

[33mcommit c91b865437f37822bec259c555eab2075d0efb7f[m
Author: Tim Bannister <tim@scalefactory.com>
Date:   Fri Nov 27 19:35:27 2020 +0000

    Add hashing script for local preview container
    
    This tool helps set the right container image label for the local
    preview tool.

[33mcommit 9d3de831360c45913cc120ff4880761a8c4e0da6[m
Author: Tim Bannister <tim@scalefactory.com>
Date:   Fri Nov 27 19:22:17 2020 +0000

    Fix image name for local previewing
    
    The name "kubernetes-hugo" came from the Kubernetes website repo where
    this Makefile originated.

[33mcommit 47184d85aed54f4aa3845d04cea4392430341f92[m
Author: Tim Bannister <tim@scalefactory.com>
Date:   Fri Nov 27 19:31:50 2020 +0000

    Use YouTube shortcode for videos
    
    Switch from using inline HTML to a Hugo shortcode that references the
    same YouTube videos.

[33mcommit 6629a27daea8b6684782da1ff9f0136b8898925f[m
Author: Tim Bannister <tim@scalefactory.com>
Date:   Fri Nov 27 19:28:21 2020 +0000

    Add README details about local previewing

[33mcommit c56c073b1742315f2e6cdcfe4771b3e658bf2acd[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Nov 24 17:43:36 2020 -0500

    add auto-gen resource removal

[33mcommit 10fb2972725c016a7d1367a23f3d6a7aaa7bd24f[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Nov 24 10:09:51 2020 -0500

    add retroactive generate procedure

[33mcommit 9c06d8a1f41b5a8b31ff631982dc432f2c94604e[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Nov 22 18:53:39 2020 -0500

    simple install instructions

[33mcommit 1433dcb976c19d6e5acd80d919a3c53270a1b4bf[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sun Nov 22 10:37:00 2020 -0500

    updates

[33mcommit 8fbb7bff2370034256e8cf4a105c0ad8b85c9194[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Nov 21 21:18:08 2020 -0500

    reorder sections

[33mcommit 6797c639edaa497a6e155f19cbf72ed34572b5ca[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Nov 21 19:20:30 2020 -0500

    test and fix examples in deny

[33mcommit cf93eb593574d1267d275be3a85758c39b2be68c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Nov 21 18:06:06 2020 -0500

    installation fixes

[33mcommit 51da06b18091280467d4d225d22c2f1d5c8332f1[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Nov 21 17:55:57 2020 -0500

    validate updates

[33mcommit 020f8e9865197f9d3cec9d04e956ad1ab8cf398b[m
Merge: 898e936a 3c78e436
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Nov 19 20:20:19 2020 -0800

    Merge pull request #39 from kyverno/dev
    
    Updates to validate and background

[33mcommit 3c78e436d8668e4163d52d7a54904cff516d2ffc[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Nov 19 12:56:36 2020 -0500

    JMESPath tweak

[33mcommit ffe9640ca7a1399999290cee029557bcd6fe4e39[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Nov 19 12:49:20 2020 -0500

    fix format

[33mcommit 3819c32b7d3a00685e32a7eb83c06e895ccdfb1c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Nov 19 12:47:46 2020 -0500

    fix format

[33mcommit 763ae5badb40cf92f1d180b81e450913f39fb55b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Nov 19 12:43:49 2020 -0500

    expand variables section

[33mcommit ce848f25e728dc2a2fc8cc99685f47864c1653aa[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Nov 19 08:08:55 2020 -0500

    background update with relref

[33mcommit 2bdec6532e74216b8635c1a3931ebcfb0bdc4059[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Thu Nov 19 07:39:16 2020 -0500

    test prism syntax highlighting

[33mcommit c1e4778f5704e439d0207ebc700c32ec3c5630a9[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 18 21:16:13 2020 -0500

    test push to check rendering on Background page

[33mcommit ff21b239c577d762d3e27d65baf23db5ea3e1a19[m
Merge: bb118f2f 898e936a
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Nov 18 13:51:20 2020 -0800

    Merge branch 'main' into dev

[33mcommit bb118f2fdc2772bc66100c6c7dca70a005be7beb[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Nov 18 13:44:41 2020 -0800

    revert 502520e5d290f5dd4a8786e81de9f2d91e49f57e

[33mcommit 898e936a0255ca97fb624447fe49900d62fbd7b8[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Mon Nov 16 18:20:22 2020 -0500

    Update Samples to point to main branch

[33mcommit 3c954011a328cc29800f4b50ae5380b399ff9b6e[m
Merge: f7c259dc 763ae0c9
Author: shuting <shutting06@gmail.com>
Date:   Mon Nov 16 10:35:29 2020 -0800

    Merge pull request #36 from kyverno/feature/add_cncf_sandbox_footer
    
    add CNCF footer

[33mcommit 763ae0c9d8f5349d5a8b24355c26eb7bcc3f25f8[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Nov 16 09:25:20 2020 -0800

    add CNCF footer

[33mcommit f7c259dc3e2392ae03d3f56d64cd62a23ffa916b[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Nov 14 21:06:22 2020 -0500

    add dates to resources

[33mcommit ca22d2d3ce7400dd2dff5093cec4a4a93cd40db5[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Nov 14 17:59:58 2020 -0500

    minor fixes

[33mcommit 923128610eeb9f565e994d715def3c8c242378ce[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Nov 14 11:14:46 2020 -0500

    add structure details

[33mcommit 6df4043d313b0e2c2f1c5fc27d298fe2d1551df0[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Sat Nov 14 10:51:45 2020 -0500

    typos; linting

[33mcommit 33a1b7075bd63771156ab038fd54b7b4192fbe95[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Nov 13 12:29:23 2020 -0500

    update example to be consistent

[33mcommit 5aa205bca32bdce0c9240b1879b4f7eb011fd018[m
Merge: c68f2e1f abd230ef
Author: shuting <shutting06@gmail.com>
Date:   Thu Nov 12 13:27:04 2020 -0800

    Merge pull request #31 from kyverno/bugfix/clarify_background_scan
    
    update background scan

[33mcommit abd230ef67e46e9548758eb508d85f6be03d4726[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Nov 12 11:47:23 2020 -0800

    update background scan

[33mcommit d3a73a484c5748e3ff25899da2c3f848a9c10fea[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Nov 12 11:33:37 2020 -0800

    update generate docs
    
    Fixes https://github.com/kyverno/website/issues/28

[33mcommit c68f2e1f5e85eb1e51cb2ce67322e245fc283c57[m
Merge: d9b57540 12c463b5
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Nov 12 11:17:00 2020 -0800

    Merge pull request #27 from kyverno/realshuting-patch-1
    
    update install command

[33mcommit d9b57540fa03c7cd103c14c7467f963e8530cc18[m
Merge: 6cc7eab2 78a23bde
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Nov 12 09:49:52 2020 -0800

    Merge pull request #29 from kyverno/realshuting-patch-2
    
    Update namespace name in JMESPath

[33mcommit 78a23bde34aea845051782be122f910961fa5f27[m
Author: shuting <shutting06@gmail.com>
Date:   Thu Nov 12 09:48:21 2020 -0800

    update namespace name in JMESPath

[33mcommit 12c463b5c6c0842d6cece7cb0abbde3da8245257[m
Author: shuting <shutting06@gmail.com>
Date:   Wed Nov 11 16:05:18 2020 -0800

    update install command

[33mcommit 6cc7eab2e85b7e39ec1d438490bab932f878aa50[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 11 16:50:33 2020 -0500

    add note about support of variables in a rule

[33mcommit 7483b6b87cec097e9c723b3425d9c68c89dad282[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 11 14:14:47 2020 -0500

    clarify ConfigMap dynamic lookups

[33mcommit b10f9eade7c04777213bbd8385e53efd2be79ee2[m
Merge: 28b885ab 8a60c06c
Author: shuting <shutting06@gmail.com>
Date:   Wed Nov 11 11:04:35 2020 -0800

    Merge pull request #26 from kyverno/bugfix/23_JMESPATH_escape
    
    add note on escaping "-" for JMESPATH processing

[33mcommit 8a60c06cd962f268f1f70ccfeb79299a91ec3def[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Nov 11 10:57:48 2020 -0800

    add note on escaping "-" for JMESPATH processing
    
    Fixes #23

[33mcommit 28b885ab85c5a4dfe45a71ba0ab7296c4578edfd[m
Merge: 573416aa 68a8bbce
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Nov 11 10:36:00 2020 -0800

    Merge pull request #24 from chipzoller/main
    
    Various typos and MD linting

[33mcommit 68a8bbced4470724fdb1a3be34fe41ee4fe86b7a[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 11 12:20:20 2020 -0500

    typos; linting

[33mcommit ce7b764dd78b8fd6113a2030efa44e1c63cf8750[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 11 12:17:49 2020 -0500

    linting

[33mcommit 68a4dbe278723a040495c8467e7757ca7da2209c[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 11 12:13:16 2020 -0500

    typos; linting

[33mcommit f5a2be8daa47741c703a867405f6320c8314ef3d[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 11 12:08:52 2020 -0500

    typos; linting

[33mcommit 362e8414f357ff9c285391a3d8bf9f509b1b6e85[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 11 11:54:14 2020 -0500

    typos

[33mcommit a57e27bf4697f39bdaeefcef6762c118604acab3[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 11 11:51:32 2020 -0500

    fix typos

[33mcommit f83745f19002e26f50db6919f8f6d85521de7093[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 11 11:12:21 2020 -0500

    adjust ConfigMap examples; MD linting

[33mcommit 8bacef101775c0e3185b6b921f9e58e3afee8872[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Wed Nov 11 11:06:45 2020 -0500

    fixing `exclude` statements with `resources` object

[33mcommit 573416aaaae37b1112001994b7e8bebefacb217d[m
Merge: 99d8b2b2 f28b14c7
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Nov 10 16:31:03 2020 -0800

    Merge pull request #18 from realshuting/patch-1
    
    Update exclude "kube-system" example

[33mcommit 99d8b2b2a21a02cbf9fc8d95d2ca32343a1160d2[m
Merge: 1196a946 aee55fe6
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Nov 10 16:30:25 2020 -0800

    Merge pull request #20 from chipzoller/patch-3
    
    Update match-exclude.md

[33mcommit aee55fe61de22737168c5ad26f43ab592d160ade[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Tue Nov 10 17:55:49 2020 -0500

    Update match-exclude.md
    
    Clarifying the filters for `match`/`exclude`. Also per here (https://kyverno.io/docs/writing-policies/match-exclude/#match-example) which says Kind is required, clarifying.

[33mcommit f28b14c72066f72131c434e911962b5ec1f452c6[m
Author: shuting <shutting06@gmail.com>
Date:   Tue Nov 10 11:04:36 2020 -0800

    Update exclude "kube-system" example

[33mcommit 1196a9465df38daa7314bdc4f00dda47b0f87e89[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Nov 8 22:35:37 2020 -0800

    fix typo

[33mcommit 2e8445927d8fbb526837351973dd8831998f4a81[m
Merge: d02bdbb1 8a7fa3c4
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Nov 8 21:55:17 2020 -0800

    Merge pull request #16 from kyverno/13_policy_precedence
    
    document ordering and (lack of) override behaviors

[33mcommit d02bdbb1387aa0d64d7b09ab4a96b37ef8e27a2b[m
Merge: bfe0472e 381359a0
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Nov 8 21:55:05 2020 -0800

    Merge pull request #17 from kyverno/docs_add_blog
    
    add blog post

[33mcommit 381359a08011276bb0567bb2b06bc7658264ff0f[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 7 20:27:20 2020 -0800

    add blog post

[33mcommit 8a7fa3c4fb94d2a7ec00631349f4cd874f91b1b5[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 7 20:10:35 2020 -0800

    document ordering and (lack of) override behaviors

[33mcommit bfe0472e76090568b89606523a53d0c5c21e7167[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 7 12:32:36 2020 -0800

    replace master with main

[33mcommit 9c6e33770c260db347873a825a055e65a0e820cf[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 7 12:31:04 2020 -0800

    replace master with main

[33mcommit 3ae78cd3a6a8ffea5aab211573a4a34f15bb2323[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Nov 7 12:29:55 2020 -0800

    replace master with main

[33mcommit be0a4c1b2201bad75c96e7e2af9c4cc9ba1fe8c5[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Oct 31 23:09:56 2020 -0700

    add version
    
    add helm version

[33mcommit 667c9e8430b85f28c808c8a221b8c7471411ef3d[m
Merge: d18bfd5b c9f68104
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Oct 30 10:40:32 2020 -0700

    Merge pull request #12 from chipzoller/patch-2
    
    Update _index.md

[33mcommit c9f68104abaa7aae21f3658b82453b52db391f11[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Oct 30 10:39:46 2020 -0700

    remove YAML example
    
    consolidate options to the simplest possible for quick start

[33mcommit d18bfd5bb21769b9e1bdb7051aaa134746b549f0[m
Merge: 82c95dea f502f8cc
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Oct 30 10:35:48 2020 -0700

    Merge pull request #11 from chipzoller/patch-1
    
    Update _index.md

[33mcommit e409048d521061735a81853080cb0b0821046687[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 30 12:31:50 2020 -0400

    Update _index.md
    
    Add imperative command to create pod satisfying ClusterPolicy previously created.

[33mcommit f502f8ccf6a839810dda0b4082acff57bda60712[m
Author: Chip Zoller <chipzoller@gmail.com>
Date:   Fri Oct 30 10:39:55 2020 -0400

    Update _index.md
    
    Use the `--create-namespace` flag of Helm 3 to consolidate commands.

[33mcommit 82c95deac1daaf7f156d87fac7d305292065cfb6[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Oct 29 12:34:19 2020 -0700

    shorten title

[33mcommit 679107dda6e3c3af13d8af8a95ce26dc3c3a675f[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Oct 29 12:32:52 2020 -0700

    update title

[33mcommit e3a9919321e9e057aca612e014bbde4a477792d4[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Oct 29 12:22:50 2020 -0700

    add operate usage notes

[33mcommit 62f9588dc8cc68f189ac9a799e0186d972c1ad91[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Thu Oct 29 12:18:11 2020 -0700

    remove deprecated operators

[33mcommit 45709f4e97a3707cb404081d81409829de231c5d[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 26 12:35:37 2020 -0700

    update message

[33mcommit 3d6d08276cb19ee1e156ae72237581f5bf3d59af[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 26 12:32:24 2020 -0700

    fix  headers

[33mcommit 595fad1bce392c0ef322a1fd5f82571707865476[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 26 12:31:41 2020 -0700

    update examples

[33mcommit 7dcc61b3287c6d32ccbcedb86be3330b218d0192[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 26 10:48:12 2020 -0700

    add link to preconditions

[33mcommit 6b42015192c99c5bbf1d1da68e4877546db0a03a[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Oct 24 17:02:11 2020 -0700

    shorten titles and remove --fqdn-as-cn option

[33mcommit 0f16b4c18398f0fb8b7186080cdfd4c2379b2c9f[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Oct 24 16:48:08 2020 -0700

    organize all configuration in a top level section

[33mcommit 5ddee42ce1ea4d67cc1ca26f562965a6c0155cad[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 21 00:18:32 2020 -0700

    update community links

[33mcommit 830c8188064f1e31803070b632c717c43a65bf8c[m
Merge: b8f1c3ca f00a18a5
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 21 00:03:22 2020 -0700

    Merge branch 'main' of https://github.com/kyverno/website into main

[33mcommit b8f1c3ca3961562f4a0b15ad9bfc6a58eebacf07[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 21 00:03:08 2020 -0700

    update branch

[33mcommit f00a18a5104906f2d0d9a15692765d43e57ed8a6[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Oct 20 23:48:43 2020 -0700

    remove info duplicated on the repo contributing page

[33mcommit 124e6b3dc53a935fb08eb99e1e5ee590505c4521[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Oct 20 21:33:23 2020 -0700

    remove dev mode install (its already in the Wiki)

[33mcommit e399e80155351bef6ca91e5d291d39504a3519ce[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 19 23:39:39 2020 -0700

    fix search

[33mcommit 60a2ac7d6316473c6940cc7c1711569767a9d13c[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Mon Oct 19 23:21:13 2020 -0700

    enable search

[33mcommit 912dc6a58da9f649f82fe3bc379879213bea2d32[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sat Oct 17 19:50:15 2020 -0700

    add badges

[33mcommit 674d5635145274d37b26308a35ef02d12d9bd523[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Fri Oct 16 00:49:34 2020 -0700

    fixed links and text

[33mcommit 502520e5d290f5dd4a8786e81de9f2d91e49f57e[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Thu Oct 15 20:15:44 2020 +0530

    development branch setup

[33mcommit d90083d40208252440a9cb09018a6badff836e7c[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 18:24:55 2020 -0700

    update CRD

[33mcommit a8d849d8bf710bb8ac9d857c826c270ec8ea6304[m
Merge: eb20b849 5314a86d
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 16:00:04 2020 -0700

    Merge branch 'main' of https://github.com/kyverno/website into main

[33mcommit eb20b849801498b33762532b2edcf803bf65ade5[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 15:59:11 2020 -0700

    add community and roadmap

[33mcommit 5314a86d733da4ff7ab03e0c3f4b718eec0dc736[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 14:34:07 2020 -0700

    Update README.md

[33mcommit 9559f6b3c108173c27502cb0e3bf0928b01f0f83[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 13:54:55 2020 -0700

    update

[33mcommit 8abd7ea2976799ff19041929a1349c3e1ffe33cc[m
Merge: 241a3305 f4c1e3de
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 13:50:19 2020 -0700

    Merge branch 'main' into initial_website

[33mcommit f4c1e3de8a04be54ab3c47eb43da183c4092c4ce[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 13:23:19 2020 -0700

    remove themes/docsy

[33mcommit 6114704c958d46bc4942c8dd06da44625dad159e[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 13:12:45 2020 -0700

    clone and add docsy directly in repo

[33mcommit a5a73f2fcf7862270291ff5cb4f22e3474172aef[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 13:11:25 2020 -0700

    Removed submodule

[33mcommit c618335402c7b6a29fcd0d4bd8928482a69c0c9f[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 13:02:09 2020 -0700

    update resources

[33mcommit 892889d907e0b36f04087bc1bed6881e1cc62936[m
Merge: 486537c5 32b90f63
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 11:22:36 2020 -0700

    Merge pull request #9 from kyverno/initial_website
    
    Initial website

[33mcommit 32b90f636bc8befe371f5ad2c4e3e25d0103a5ba[m
Merge: 241a3305 486537c5
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 11:18:14 2020 -0700

    Merge branch 'main' into initial_website

[33mcommit 241a3305bfba1cb1480df10c48d181df067b1ec0[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 11:12:16 2020 -0700

    update base URL

[33mcommit a81a574125a20652d86f84e28fdbbf5bc0cac156[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 11:08:42 2020 -0700

    add background and remove github from footer

[33mcommit 0bb7a8ceac3ec97e6ef9bed6ffd1654502aaf6a0[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 10:06:07 2020 -0700

    fix links

[33mcommit f3ebe5552209e588eef4d91ba83a09a0d18c704d[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 01:03:58 2020 -0700

    update base URL

[33mcommit 307e6ebeefecf5a3ad63ddbe5ab94f47a02c9ea3[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 00:56:49 2020 -0700

    add missing files

[33mcommit a1577a7f530dd71b2af8eb9a966ec8c277e67471[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Wed Oct 14 00:52:04 2020 -0700

    update docs and resources

[33mcommit bc139249bf4e45fc5e9bb65b1b5e096afa64e013[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Tue Oct 13 17:58:09 2020 -0700

    update front page

[33mcommit 17fbdbd74c00544ac18fe91c0b62f0083ccfe774[m
Merge: 9ffce47f ef65f601
Author: Yuvraj <10830562+evalsocket@users.noreply.github.com>
Date:   Tue Oct 13 04:44:46 2020 +0530

    Merge pull request #8 from evalsocket/init
    
    Added submodules

[33mcommit ef65f6016c633f5e9114b5f9ceef206d4063db39[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Tue Oct 13 04:29:12 2020 +0530

    Added submodules

[33mcommit 9ffce47f0fdcd9704344f218289dacf6013682c6[m
Merge: a80ed25a 432db016
Author: Yuvraj <10830562+evalsocket@users.noreply.github.com>
Date:   Tue Oct 13 03:34:25 2020 +0530

    Merge pull request #7 from evalsocket/init
    
    Init

[33mcommit 432db016b1c2125a5ad7f04d68647305c884065d[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sun Oct 11 16:42:16 2020 +0530

    More changes

[33mcommit f119ca49a7cac1ea2585d44c3b4b97b0e7eba833[m
Merge: 3f1d4e01 a80ed25a
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sun Oct 11 16:35:58 2020 +0530

    More changes

[33mcommit 486537c55dd027a79a585861392ca60016ccdc7e[m
Merge: b804314c 87bfadd4
Author: Yuvraj <10830562+evalsocket@users.noreply.github.com>
Date:   Sun Oct 11 16:18:50 2020 +0530

    Merge pull request #6 from evalsocket/main
    
    Revert main

[33mcommit 87bfadd451a9068238a0a026d40d052d53b86701[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sun Oct 11 16:17:50 2020 +0530

    Revert main

[33mcommit a80ed25a20c77f3391301487a0f33e8ee5b5c4a8[m
Merge: 0780f51f 7f3c93bc
Author: Yuvraj <10830562+evalsocket@users.noreply.github.com>
Date:   Sun Oct 11 00:59:03 2020 +0530

    Merge pull request #5 from kyverno/revert-4-initial_website
    
    Revert 4 initial website

[33mcommit 7f3c93bc0238c0e318af8f69f6a9348c788a7714[m
Author: Yuvraj <10830562+evalsocket@users.noreply.github.com>
Date:   Sun Oct 11 00:58:22 2020 +0530

    Revert "Samples Added"

[33mcommit b804314c7729fb065b52d4b6b61e16efacfc8d45[m
Merge: 01f51d3b 0780f51f
Author: Yuvraj <10830562+evalsocket@users.noreply.github.com>
Date:   Sun Oct 11 00:58:12 2020 +0530

    Merge pull request #4 from kyverno/initial_website
    
    Samples Added

[33mcommit 3f1d4e01ef6e09bc0db10fc4bea84b57ffbb88dc[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sun Oct 11 00:55:38 2020 +0530

    More changes

[33mcommit bd74c079cc30a80d83d5af3b529c1ad7678b16ab[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sun Oct 11 00:52:55 2020 +0530

    More changes

[33mcommit 43b5cef5d61c0b436e3080492538cc66ebdc873a[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sun Oct 11 00:50:22 2020 +0530

    More changes

[33mcommit f77ed70b594d4dde7a3af96abc0a501dbb8b2a21[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sun Oct 11 00:49:31 2020 +0530

    More changes

[33mcommit 5d0c6bbc047f4227b9e653a04cece4910980392b[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sun Oct 11 00:48:06 2020 +0530

    More changes

[33mcommit 0780f51fa36da39159d0c9cb9eb5ad757223311f[m
Merge: a3a0f318 c49d75ef
Author: Yuvraj <10830562+evalsocket@users.noreply.github.com>
Date:   Sun Oct 11 00:23:16 2020 +0530

    Merge pull request #3 from evalsocket/init
    
    Update docs

[33mcommit c49d75efd1b507017ba3565b8070964b0f7303ee[m
Merge: 2be06f8b e4dc432b
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sun Oct 11 00:20:02 2020 +0530

    Merge branch 'init' of https://github.com/evalsocket/website-1 into init

[33mcommit 2be06f8b264cb7f8348a9d79b574c3c25cbcf204[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sun Oct 11 00:19:41 2020 +0530

    More changes

[33mcommit e4dc432ba62015e624cf1529136195884e24297e[m
Merge: 7214e497 a3a0f318
Author: Yuvraj <10830562+evalsocket@users.noreply.github.com>
Date:   Sun Oct 11 00:08:04 2020 +0530

    Merge branch 'initial_website' into init

[33mcommit 7214e497c11507fcf5db1d0f1f9b8f8cf15952dd[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sun Oct 11 00:05:51 2020 +0530

    Update docs

[33mcommit a3a0f318ffdb5d5ef0b0b7dd19ad331cd14424ab[m
Merge: 71ca3575 38414944
Author: Yuvraj <10830562+evalsocket@users.noreply.github.com>
Date:   Sat Oct 10 01:03:19 2020 +0530

    Merge pull request #2 from kyverno/evalsocket-patch-1
    
    Remove tab

[33mcommit 38414944d1e17e0bb4589e67ae9b5ae186ece10d[m
Author: Yuvraj <10830562+evalsocket@users.noreply.github.com>
Date:   Sat Oct 10 01:03:01 2020 +0530

    Remove tab

[33mcommit 71ca357540908deda75387459d197470851f53a9[m
Merge: e87d1148 d96bd2d9
Author: Yuvraj <10830562+evalsocket@users.noreply.github.com>
Date:   Sat Oct 10 01:01:47 2020 +0530

    Merge pull request #1 from evalsocket/init
    
    Website added

[33mcommit d96bd2d9cd482a7caad722d9674b4c2902cf6fe0[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sat Oct 10 00:56:41 2020 +0530

    init

[33mcommit e87d1148e868758b19b33b53e7f219b11e608b33[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sat Oct 10 00:47:01 2020 +0530

    init

[33mcommit dd66b9428ccba76b3e3b8cc45a8bfd7b200e9a2a[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sat Oct 10 00:43:41 2020 +0530

    More changes

[33mcommit 449d6d455aa69efbdfb6dc0b7cb80d8018dd0bfd[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sat Oct 10 00:35:02 2020 +0530

    More changes

[33mcommit 539c3b5a5e9c1d125c925dc055b605a5d2962af5[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sat Oct 10 00:33:32 2020 +0530

    More changes

[33mcommit cb048377ede3668faff4fd1b8c5e957009f12632[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sat Oct 10 00:28:01 2020 +0530

    More changes

[33mcommit a096b89af572f931985851aba3177f2863759294[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sat Oct 10 00:26:35 2020 +0530

    More changes

[33mcommit 759fd94372fd129b1854b9470ef1cd56c8305560[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Sat Oct 10 00:25:29 2020 +0530

    More changes

[33mcommit 345b4ff0ee24b2712c3e43ff91a6a303868ed32c[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Fri Oct 9 23:20:31 2020 +0530

    More changes

[33mcommit 430d4c7b57cf7b19d6a08df05c48cb12f78c9bc0[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Fri Oct 9 23:14:10 2020 +0530

    More changes

[33mcommit 3d93747afc549da1fbf2c8ee0a1eeaa0a034ed6c[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Fri Oct 9 22:54:04 2020 +0530

    More changes

[33mcommit 5cade034aee0a334d61033ea086833d68573b0a5[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Fri Oct 9 22:48:41 2020 +0530

    More changes

[33mcommit 56e276228c546734b997c3fbc5b6161999e7b2fd[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Fri Oct 9 22:30:05 2020 +0530

    More changes

[33mcommit 7c15f7b1efdf1fc469e3c12ff076a031a990ebef[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Fri Oct 9 22:10:21 2020 +0530

    remove theme from code

[33mcommit b67b61593522231eb5d21a916e521da79b8f13e2[m
Author: evalsocket <yuvraj.yad001@gmail.com>
Date:   Tue Oct 6 09:36:56 2020 -0700

    Init

[33mcommit 01f51d3b0c15bc5f5191194c37ad766820502734[m
Author: Jim Bugwadia <jim@nirmata.com>
Date:   Sun Oct 4 17:36:52 2020 -0700

    Initial commit
