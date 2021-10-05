# How to Contribute
We welcome all contributions, suggestions, and feedback, so please do not hesitate to reach out!

 
We'd love to accept your patches and contributions to this project. There are
just a few small guidelines you need to follow.

## Contributor License Agreement

Contributions to this project must be accompanied by a Contributor License
Agreement. You (or your employer) retain the copyright to your contribution;
this simply gives us permission to use and redistribute your contributions as
part of the project. Head over to <https://cla.developers.google.com/> to see
your current agreements on file or to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

## Code reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.

## Community Guidelines

This project follows
[Google's Open Source Community Guidelines](https://opensource.google.com/conduct/).

## Ways You Can Contribute
   - [Report Issues](https://github.com/kyverno/website/blob/main/CONTRIBUTING.md#report-issues)
   - [Submit Pull Requests](https://github.com/kyverno/website/blob/main/CONTRIBUTING.md#submit-pull-requests)
   - [Fix or Improve Documentation](https://github.com/kyverno/website/blob/main/CONTRIBUTING.md#fix-or-improve-documentation) 
   - [Join Our Community Meetings](https://github.com/kyverno/website/blob/main/CONTRIBUTING.md#join-our-community-meetings) 
### Report issues
   - Report potential bugs
   - Request a feature
   - Request a sample policy

### Submit Pull Requests
#### Setup local development environments 
-  Please refer to [README](https://github.com/kyverno/website#readme) for local setup.
####  Submit a PR for [open issues](https://github.com/kyverno/kyverno/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)

### Fix or Improve Documentation
   - [Kyverno Docs](https://github.com/kyverno/website)
   #### Get started

Head over to project repository on github and click the **"Fork"** button. With the forked copy, you can try new ideas and implement changes to the project.

 1.  **Clone the repository to your device:**

To clone this repository, copy the link of below, paste it in your device terminal and replace the *YOUR-GITHUB-ID* with your Github ID.

```
$ git clone https://github.com/{YOUR-GITHUB-ID}/website kyverno-website/ --recurse-submodules

```

 2. Then navigate to the local folder and build the website for local viewing of changes using this command:

```
cd kyverno-website

hugo server -v
```
 3. **Create a branch:** 

 Create a new brach and navigate to the branch using this command.

 ```
 $ git checkout -b <new-branch>
 ```

 Great, its time to start hacking, You can now go ahead to make all the changes you want.


 4. **Stage, Commit and Push changes:**

 Now that we have implemented the required changes, use the command below to stage the changes and commit them.

 ```
 $ git add .
 ```

 ```
 $ git commit -s -m "Commit message"
 ```

 The -s signifies that you have signed off the the commit.

 Go ahead and push your changes to github using this command.
 
 ``` 
 $ git push 
 ```


Before you contribute, please review and agree to abide by our community [Code of Conduct](/CODE_OF_CONDUCT.md).


### Join Our Community Meetings
 The easiest way to reach us is on the [Kubernetes slack #kyverno channel](https://app.slack.com/client/T09NY5SBT/CLGR9BJU9). 
 
## Developer Certificate of Origin (DCO) Sign off

For contributors to certify that they wrote or otherwise have the right to submit the code they are contributing to the project, we are requiring everyone to acknowledge this by signing their work.

To sign your work, just add a line like this at the end of your commit message:

```
Signed-off-by: Random J Developer <random@developer.example.org>
```

This can easily be done with the `-s` command line option to append this automatically to your commit message.
```
$ git commit -s -m 'This is my commit message'
```

By doing this you state that you can certify the following (https://developercertificate.org/):
```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
1 Letterman Drive
Suite D4700
San Francisco, CA, 94129

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.


Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```
