# Use the latest arch with base-devel
FROM base/devel

# By Rohit Goswami
LABEL maintainer="Rohit Goswami (HaoZeke) <rohit.1995@mail.ru>"
LABEL name="docuYoda"

# Add archLinuFr and install all the packages (including AUR stuff)
RUN  echo -e \ 
"\n[archlinuxfr]\nSigLevel = Never\nServer = http://repo.archlinux.fr/\$arch" \
>> /etc/pacman.conf && pacman-key --refresh-keys && \
pacman-key -r 753E0F1F && pacman-key --lsign-key 753E0F1F && \
pacman -Syy && echo | pacman --noconfirm -S python-pip texlive-most yarn tup pandoc \
pandoc-citeproc sassc git biber openssh yaourt && \
yaourt -S --noconfirm --noedit pp-git

# Switch to the new user by default and make ~/ the working dir
ENV USER docuyoda

# Add the build user, update password to build and add to sudo group
RUN useradd --create-home ${USER} && \
echo "${USER}:${USER}" | chpasswd && usermod -aG wheel ${USER} && \
echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Use ccache by default
ENV USE_CCACHE 1

# Fix permissions on home
RUN chown -R ${USER}:${USER} /home/${USER} && \
sudo -u ${USER} mkdir -p /home/${USER}/aur

# Switch to ${USER}
USER ${USER}
WORKDIR /home/${USER}/

# Extras
RUN sudo pip install panflute pandoc-eqnos pandoc-fignos \
pandoc-xnos pandoc-tablenos

# Setup dummy git config
RUN git config --global user.name "${USER}" && \
git config --global user.email "${USER}@localhost"
