package com.aaronep.andy.myplayground;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.content.LocalBroadcastManager;
import android.widget.Toast;

/**
 * Created by aaronep on 3/2/18.
 */




public class MyDialogFragment extends DialogFragment {
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {


        //gets the activity that this will show up on top of
        AlertDialog.Builder theDialog = new AlertDialog.Builder(getActivity());

        // Set the title for the Dialog
        theDialog.setTitle("Sample Dialog");

        // Set the message
        theDialog.setMessage("Hello I'm a Dialog");

        // Add text for a positive button
        theDialog.setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {

                Toast.makeText(getActivity(), "Clicked OK", Toast.LENGTH_SHORT).show();
                LocalBroadcastManager.getInstance(getActivity()).sendBroadcast(
                        new Intent("SOME_ACTION"));

            }
        });

        // Add text for a negative button
        theDialog.setNegativeButton("CANCEL", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {

                Toast.makeText(getActivity(), "Clicked Cancel", Toast.LENGTH_SHORT).show();
                LocalBroadcastManager.getInstance(getActivity()).sendBroadcast(
                        new Intent("OTHER_ACTION"));

            }
        });



        // Returns the created dialog
        return theDialog.create();

    }
}
