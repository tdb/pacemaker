#!/bin/bash
#
# Copyright (C) 2015 Andrew Beekhof <andrew@beekhof.net>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

if [ -z $CRM_alert_version ]; then
    echo "Pacemaker version 1.1.15 is required" >> ${CRM_alert_recipient}
    exit 0
fi

tstamp=`printf "%04d. " "$CRM_alert_node_sequence"`
if [ ! -z $CRM_alert_timestamp ]; then
    tstamp="${tstamp} $CRM_alert_timestamp (`date "+%H:%M:%S.%06N"`): "
fi

case $CRM_alert_kind in
    node)
	echo "${tstamp}Node '${CRM_alert_node}' is now '${CRM_alert_desc}'" >> ${CRM_alert_recipient}
	;;
    fencing)
	# Other keys:
	# 
	# CRM_alert_node
	# CRM_alert_task
	# CRM_alert_rc
	#
	echo "${tstamp}Fencing ${CRM_alert_desc}" >> ${CRM_alert_recipient}
	;;
    resource)
	# Other keys:
	# 
	# CRM_alert_target_rc
	# CRM_alert_status
	# CRM_alert_rc
	#
	if [ ${CRM_alert_interval} = "0" ]; then
	    CRM_alert_interval=""
	else
	    CRM_alert_interval=" (${CRM_alert_interval})"
	fi

	if [ ${CRM_alert_target_rc} = "0" ]; then
	    CRM_alert_target_rc=""
	else
	    CRM_alert_target_rc=" (target: ${CRM_alert_target_rc})"
	fi
	
	case ${CRM_alert_desc} in
	    Cancelled) ;;
	    *)
		echo "${tstamp}Resource operation '${CRM_alert_task}${CRM_alert_interval}' for '${CRM_alert_rsc}' on '${CRM_alert_node}': ${CRM_alert_desc}${CRM_alert_target_rc}" >> ${CRM_alert_recipient}
		;;
	esac
	;;
    *)
        echo "${tstamp}Unhandled $CRM_alert_kind alert" >> ${CRM_alert_recipient}
	env | grep CRM_alert >> ${CRM_alert_recipient}
        ;;

esac
