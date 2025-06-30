# Deploy anything on AWS !

1. Execute this in CloudShell or similar

```
cd ~
rm -rf aws-deploy
git clone https://github.com/2ndSightLab/aws-deploy.git
cd aws-deploy
chmod 700 deploy.sh
./deploy.sh
```

2. Enter an environment (like dev, qa, prod - it's just used in names)

3. Enter the service of the resource you want to deploy (Case sensitive. Type help for a list of resources.)

4. Enter the resource type you want to deploy. (Case sensitive. Type help for a list of resources.)

5. The CloudFormation script is generated and name is printed to screen. You can go look at it.

6. The script to deploy the CloudForamtion template is generated.

7. You will be prompted for property values. Enter as needed, skip optional as needed.

8. The script executes and deploys the CloudForamtion stacks.
   
# Revisions:

6/30/25 - fixed issue: empty parameter list didn't work, allowed values added to wrong parameter\
6/30/25 - added support for sub resources\
6/29/25 - created new public repo for aws-deploy code

# Known Issues:

Policies do not follow the formal model.\
Things with JSON like Step Function configurations are huge blobs in a single property - you're on your own.\
^^^^ and this is why everything should be first class CloudFormation citizen rather than a blog of JSON in a property!

# FYI on GitHub Repos:

I do not like that AWS CloudShell has a github credential helper that wants you to store your credentials. To prompt for credentials instead run this:

```
git config --global --unset credential.helper
```

I am trying out this method of working in the test repository and then pushing working code to the public repository. We'll see how this works out. (Got Gemini to write this with a lot of coaxing to get it to show me what I actually wanted):

```
# Navigate to your local Git repository
cd ~/aws-depoy-test

# Add the public GitHub repository as a remote (if not already added)
git remote add public https://github.com/2ndSightLab/aws-deploy

# Add the private repository as a remote (adjust URL for your private repo)
git remote add private https://github.com/2ndSightLab/aws-deploy-test

# Verify remotes are added correctly
git remote -v

# *** Workflow for making multiple private changes and pushing to public ***

# Ensure you are on the local branch where you will make private changes
# (For this workflow, we'll assume 'main' is used for private development)
git checkout main

# Fetch and merge changes from the private remote to keep the local 'main' up to date
git pull private main

# *** Make multiple changes and commit them on the local 'main' branch ***

# For each set of changes:
# git add .
# git commit -m "Commit message for private change X"

# Push the private changes to the private remote (repeat as needed)
git push private main

# *** When private changes are working and ready to share publicly ***

# Ensure the local 'main' branch has all the latest working private changes
# (This should be the case if you've been pushing to 'private main')
# git pull private main # You might run this one last time for safety

# Push the local 'main' branch (containing the working private changes) to the public remote
git push public main

# *** To switch back to making changes on the private repo (which is what you are already set up for in this workflow) ***

# You are likely already on the local 'main' branch, which is synced with the private repo's 'main'.
# If you were on a different branch temporarily, switch back:
git checkout main

# Fetch the latest changes from the private repo (in case someone else made changes)
git pull private main

# You are now ready to continue making changes, committing, and pushing to the private repo as described in the first part of this workflow.
```

To further protect your private and public repos create separate access keys. Only use the access key for the public repository when you really need it. Then make sure you remove it from memory.

> Go to GitHub Settings: Click your profile picture > Settings.\
> Find Developer Settings: Click "Developer settings" in the left sidebar.\
> Choose Fine-grained Tokens: Click "Personal access tokens" > "Fine-grained tokens".\
> Make a New Token: Click "Generate new token".\
> Name and Set Expiration: Give it a name and choose an expiration date.\
> Select Repositories:\
> Choose who owns the token: Select either your personal account or an organization.\
> Limit to specific repos: Pick "Only select repositories".\
> Choose the repos: Select the exact repositories the token needs access to.\
> Set Permissions: Choose the minimum permissions the token needs (e.g., read-only for specific actions).\
> Create and Copy: Click "Generate token" and immediately copy the token. You won't see it again.

Remove the git credentials from memory after performing required actions.

```
git credential-cache exit
```

Stop git from guessing credentials:

```
git config --global user.useConfigOnly true
git config  user.useConfigOnly true
```

Remove any existing configured credentials:
```
git config --global --unset user.name
git config --global --unset user.email
git config --unset user.name
git config --unset user.email
```

You can set the username and email for the purposes of commit, but then login with a different user when you push the code. Not sure how I feel about that in a large roganization but it keeps my details somewhat out of CloudShell, though not completely.
