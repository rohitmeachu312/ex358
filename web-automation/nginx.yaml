---
- name: Nginx web server deployment
  hosts: nginx
  become: true

  roles:
    - name: redhat.rhel_system_roles.selinux
      selinux_fcontexts:
        - target: "{{ selinux_target }}"
          setype: "{{ selinux_setype }}"
          state: present

  tasks:
    - name: Latest software installed for nginx
      ansible.builtin.dnf:
        name: "{{ nginx_packages }}"
        state: present

    - name: Web content is in place
      ansible.builtin.import_tasks: deploy_content.yml

    - name: Set up nginx serverblock
      ansible.builtin.template:
        src: "nginx.conf.j2"
        dest: "/etc/nginx/conf.d/{{ item }}.conf"
      loop: "{{ web_hosts }}"

    - name: Firewall ports are open
      ansible.posix.firewalld:
        service: "{{ item }}"
        permanent: true
        immediate: true
        state: enabled
      loop:
        - https
        - http

    - name: Nginx is enabled and started
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true
