#!/bin/bash

random_uuid_folder=$(ssh mobile@192.168.1.123 ls ~/Containers/Data/Applications | tail -1);
echo $random_uuid_folder;
