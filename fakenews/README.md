Step 1: The function fakenews has already been built and pushed and can always be deployed on OpenFaas. 
To build and push it to your own Docker account, take steps 2 to 4 before you continue with 5, if not, ignore steps 2 to 4 and move to step 5.

Step 2: Open your terminal, clone the openfaas-functions repository into your local machine, cd into the fakenews folder.

Step 3: Run this command: docker build -t your_docker_user_ID/fakenews .

Step 4: Run this command: docker push your_docker_user_ID/fakenews:latest

Step 5: While you are still in the fakenews directory on your terminal, do the necessary installations by running the command: bash setup1.sh and bash setup2.sh

Once you have run bash setup1.sh and bash setup2.sh on your machine, you don't need to rerun them when next you start your system.

Step 5a: Whenever you reboot your system, go to your terminal and switch user to userfaas by running the command: su -- userfaas

Step 5b: Cd into the fakenews directory and run the command: bash openfaas.sh

Step 6: When the setup is complete, you will see a 25-digit password on the terminal. The 25 digit password contains both letters and numbers, copy it.

Step 7: On your browser, go to http://127.0.0.1:8080/ui/

Step 8: Type the username as admin and the password as the 25-digit password you copied from your terminal, and sign in.

Step 9: Click Deploy New Function

Step 10: Click Custom

Step 11: On the Docker Image space, type tissadeking/fakenews:latest or your_docker_user_ID/fakenews:latest

Step 12: On the Function Name space, type fakenews

Step 13: At the bottom right, click Deploy

Step 14: The fakenews function would then be deployed and after some time it would be ready to be invoked
