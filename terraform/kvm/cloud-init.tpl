#cloud-config
hostname: ${hostname}

users:
  - default
  - name: daniel
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    shell: /bin/bash
    lock_passwd: false
    passwd: $6$rounds=4096$Q2Qq9qvX7lRj4E0p$CKQJ87DpvTbqz3hl8LhtP6pxYdjhmkbixVMBtG2P8lpX5gFJ2OFS62Sq37.ya5QhsrNK8aQGNgOg4cww4sxAV.
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWjCxMS6ljyJ6zUOAW5LgVLHLwAIu/TWoJTTG8Kref5n5EbzdiTtckEYs2U7scbjLIT2PDkUOIF1HYZxpYXq693O/TGfXr+zPwau4mdCvoE3ELa3JSeMbJdUr2ugrZohlTMGAx9RXpXbAJyo8vtxXhF3UFHaaFXGor3v9CBTLOpdyLe7FH7Q7G7uVvJGn2iJC6N845gZHizZtLmY9vJ8eYv9R71igtcz9bwp4Hwra+FQPZKBZWE5+94D76hON3pA2XkTUfG5mloDN+jR8p6qO8mO+z1ubqU+8tMBBrH1p2vtROSKVvVk0kxniJGtrtkyJCVW+iHAAKFn5/Gd3IDaBNGCHZJIgo5EmJ+qfp8wyD5DzsHTy6IJldmZTv91WHqKZhwpJFahpifqGGpmT2RCsqijxliDU6qqATd1FhR7VC25brEFTRb5/UvPq30ypmY1RrXD9/xQP4JE3T033cGdTRcFsnohvDYt9XPTlF0TjvHXqRcNRtntgzhYzSUMtEXAO+E0oCAw5LPreXjQh1ZQmJJ5PWxouLRaus065U9ghPhLOcxVVszWC0qIEwof21YfpkfUhrBy88cVS+3Mpwk1sd4nqbGniLbduy4Mnn8hAq0LShcL8jArKFt7RL6G8QmBOcJiWFXztm8mCkJL7HGFIdtmY26M9jJG4OexBcw1xGUw== daniel@JUNYOUNGDESKTOP

ssh_pwauth: false
disable_root: true

write_files:
  - path: /etc/ssh/sshd_config.d/hardening.conf
    content: |
      PasswordAuthentication no
      PermitRootLogin no
      PubkeyAuthentication yes

package_update: true
packages:
  - qemu-guest-agent

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - systemctl restart ssh