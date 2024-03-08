# Gitlab-ce backup and restore

## Create a repository on gitlab

The first step is to create a reository on gitlab before creating a backup.

![create-repo](create-repo.png)

## Create backup

It's a piece of cake. Run this command and wait for the system to do its job.

```bash
gitlab-backup create
```

You can find your backup file in `/var/opt/gitlab/backups/`.<br>
It is possible to change tha backup path in `/etc/gitlab/gitlab.rb` configuration `gitlab_rails['backup_path']`

```bash
ls /var/opt/gitlab/backups/

1708372789_2024_02_19_16.2.3_gitlab_backup.tar
```

## Make a change on your repository

Before restoring the backup file, to check whether the backup file is ok or not, make any changes on your repository.

In this case I added two new files to my repository and deleted the first file that I've added in the first step.

![change-repo](change-repo.png)

## Restore backup

This procedure assumes that:

- You have installed the **exact same version and type (CE/EE)** of GitLab with which the backup was created.
- You have run `gitlab-ctl reconfigure` at least once.
- GitLab is running. If not, start it using `gitlab-ctl start`.

Stop the processes that are connected to the database. Leave the rest of GitLab running:

```bash
gitlab-ctl stop puma
gitlab-ctl stop sidekiq
# Verify
gitlab-ctl status
```

![gitlab-ctl-status](gitlab-ctl-status.png)

Next, restore the backup, specifying the ID of the backup you wish to restore:

```bash
# This command will overwrite the contents of your GitLab database!
# NOTE: "_gitlab_backup.tar" is omitted from the name
gitlab-backup restore BACKUP=1708372789_2024_02_19_16.2.3
```
![gitlab-backup-restore](gitlab-backup-restore.png)

Next, restart and check GitLab:

```bash
gitlab-ctl restart
gitlab-rake gitlab:check SANITIZE=true
```

![gitlab-ctl-status](gitlab-ctl-restart.png)

Now it is time to check your gitlab, to see if your back is restores successfully to the thing you wanted or not.

![repo-after-restore](repo-after-restore.png)

## Source of content

[GitLab Docs](https://docs.gitlab.com) <br>
[GitLab Backup Docs](https://docs.gitlab.com/ee/administration/backup_restore/backup_gitlab.html) <br>
[GitLab Restore Docs](https://docs.gitlab.com/ee/administration/backup_restore/restore_gitlab.html)