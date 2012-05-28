# ==============================================================================
#   Copyright 2012 Hannes Juutilainen <hjuutilainen@mac.com>
#   https://github.com/hjuutilainen/pf-conf
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# ==============================================================================

include /usr/local/share/luggage/luggage.make

TITLE=pf-firewall
REVERSE_DOMAIN=com.github.hjuutilainen
PAYLOAD=\
	pack-Library-LaunchDaemons-com.github.hjuutilainen.pf.plist\
	pack-etc-com.github.hjuutilainen.pf.conf\
	pack-private-etc-pf.anchors-com.github.hjuutilainen.pf.rules\
	pack-private-etc-pf.anchors-com.github.hjuutilainen.pf.macros\
	pack-usr-local-bin-pf-control.sh\
	pack-usr-local-bin-pf-restart.sh\
	pack-script-postflight\
	pack-script-preflight

modify_packageroot:
	# Create a customrules directory
	@sudo mkdir -p ${WORK_D}/private/etc/pf.anchors/com.github.hjuutilainen.pf.d
	@sudo chown root:wheel ${WORK_D}/private/etc/pf.anchors/com.github.hjuutilainen.pf.d
	@sudo chmod 755 ${WORK_D}/private/etc/pf.anchors/com.github.hjuutilainen.pf.d
	# Clear extended attributes
	@sudo xattr -c ${WORK_D}/private/etc/com.github.hjuutilainen.pf.conf
	@sudo xattr -c ${WORK_D}/private/etc/pf.anchors/com.github.hjuutilainen.pf.rules
	@sudo xattr -c ${WORK_D}/private/etc/pf.anchors/com.github.hjuutilainen.pf.macros
	@sudo xattr -c ${WORK_D}/usr/local/bin/pf-control.sh
	@sudo xattr -c ${WORK_D}/usr/local/bin/pf-restart.sh
	@sudo xattr -c ${WORK_D}/Library/LaunchDaemons/com.github.hjuutilainen.pf.plist

prep-private-etc-pf.anchors: l_private_etc
	@sudo mkdir -p ${WORK_D}/private/etc/pf.anchors
	@sudo chown root:wheel ${WORK_D}/private/etc/pf.anchors
	@sudo chmod 755 ${WORK_D}/private/etc/pf.anchors

pack-private-etc-pf.anchors-com.github.hjuutilainen.pf.rules: prep-private-etc-pf.anchors
	@sudo ${CP} com.github.hjuutilainen.pf.rules ${WORK_D}/private/etc/pf.anchors
	@sudo chown root:wheel ${WORK_D}/private/etc/pf.anchors/com.github.hjuutilainen.pf.rules
	@sudo chmod 644 ${WORK_D}/private/etc/pf.anchors/com.github.hjuutilainen.pf.rules
	
pack-private-etc-pf.anchors-com.github.hjuutilainen.pf.macros: prep-private-etc-pf.anchors
	@sudo ${CP} com.github.hjuutilainen.pf.macros ${WORK_D}/private/etc/pf.anchors
	@sudo chown root:wheel ${WORK_D}/private/etc/pf.anchors/com.github.hjuutilainen.pf.macros
	@sudo chmod 644 ${WORK_D}/private/etc/pf.anchors/com.github.hjuutilainen.pf.macros
	

