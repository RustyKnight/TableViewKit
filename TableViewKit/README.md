#  TableViewKit

A set of functionality to make UITableView less "monalithical" and apply a concept of seperation between the cell/row, sections and view

## Basic concept

The kit breaks the table view down into it's separate components, sections and rows.

The kit employes a lazy approach to updates, this means that model maintains two states, a "view" state which is what is currently shown on the UI and a change state, which is the desired state the model wants to be.

At some point, the TableView will perform a batch update, at which point the "desired" state will be applied and will become the "view" state
