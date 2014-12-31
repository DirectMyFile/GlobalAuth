# Permissions

Permissions the account has. Can range from anything to custom permissions to
system permissions. The asterisk represents a wildcard. The wildcard allows the
root permission and every child permission to be granted. Permissions can be
negated with a "-" operator before the node. Negated nodes always take precedence
over granted permissions. Care is to be taken when managing permissions on your own
account, for it is easy to lock yourself out.

### Example

* GlobalAuth.Invoke.*
* -GlobalAuth.Invoke.Action

This will enable the user to invoke every action except an action named "Action"

## GlobalAuth.Invoke.*

Controls whether the user has permission to invoke the specified action. The
root node by itself will do nothing. This type of permission takes permission
children to use. The wildcard can represent every action or it can be replaced
with a specific action.

### Example

GlobalAuth.Invoke.Auth - This will give permission to invoke the "Auth" action.
                         Without this permission, a user is not allowed to log
                         into the global auth server.
