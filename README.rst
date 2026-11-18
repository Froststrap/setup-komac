setup-komac
===========

Composite GitHub Action that installs a **pinned** `Komac
<https://github.com/russellbanks/Komac>`_ release on Linux, macOS, or Windows,
verifies its SHA-256 against the checksums published with the release, and adds
it to ``PATH``.

Usage
-----

.. code-block:: yaml

   steps:
     - uses: Froststrap/setup-komac@v1
       with:
         version: "2.17.2"

     - run: komac update Froststrap.Froststrap --version 2.0.9 --urls "$MSI" --submit
       env:
         GITHUB_TOKEN: ${{ secrets.WINGET_TOKEN }}

Inputs
------

.. list-table::
   :header-rows: 1
   :widths: 10 10 10 50

   * - Input
     - Required
     - Default
     - Description
   * - ``version``
     - no
     - ``2.17.2``
     - Komac release version, without the leading ``v``.

Supported runners
-----------------

``x86_64`` and ``aarch64`` on Linux (``gnu`` libc), macOS, and Windows.

Why not just curl it?
---------------------

Two reasons:

- **Reproducible** --- the version is pinned by the caller, never resolved to
  "latest" at run time.
- **Verified** --- the downloaded binary is checked against the release's
  ``SHA256SUMS`` before it is put on ``PATH``.

Releases
--------

- ``v1`` is a floating tag that always points at the newest
  backwards-compatible release.
- Pin to a commit SHA if you want a fixed action version:

  .. code-block:: yaml

     - uses: Froststrap/setup-komac@<sha> # v1.x.y

Bumping the default Komac version is a one-line change in ``action.yml``;
Renovate can automate it with the ``github-releases`` datasource.

License
-------

This is licensed under AGPL-3.0. See ``LICENSE``.
