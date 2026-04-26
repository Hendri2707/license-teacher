// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LicenseVerification {

    address public admin;

    constructor() {
        admin = msg.sender;
    }

    struct License {
        string nama;
        string bidang;
        uint256 tanggalTerbit;
        uint256 masaBerlaku; // dalam detik
        bool aktif;
        bool exists;
    }

    mapping(address => License) private licenses;

    // 🔔 EVENT (penting untuk tracking)
    event LicenseIssued(address indexed wallet, string nama, string bidang);
    event LicenseRevoked(address indexed wallet);
    event LicenseUpdated(address indexed wallet);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Hanya admin");
        _;
    }

    // ✅ Terbitkan lisensi
    function terbitkanLisensi(
        address _wallet,
        string memory _nama,
        string memory _bidang,
        uint256 _masaBerlaku
    ) public onlyAdmin {

        require(!licenses[_wallet].exists, "Lisensi sudah ada");

        licenses[_wallet] = License({
            nama: _nama,
            bidang: _bidang,
            tanggalTerbit: block.timestamp,
            masaBerlaku: _masaBerlaku,
            aktif: true,
            exists: true
        });

        emit LicenseIssued(_wallet, _nama, _bidang);
    }

    // ❌ Cabut lisensi
    function cabutLisensi(address _wallet) public onlyAdmin {
        require(licenses[_wallet].exists, "Lisensi tidak ditemukan");

        licenses[_wallet].aktif = false;

        emit LicenseRevoked(_wallet);
    }

    // 🔄 Update lisensi
    function updateLisensi(
        address _wallet,
        string memory _nama,
        string memory _bidang,
        uint256 _masaBerlaku
    ) public onlyAdmin {

        require(licenses[_wallet].exists, "Lisensi tidak ditemukan");

        License storage l = licenses[_wallet];
        l.nama = _nama;
        l.bidang = _bidang;
        l.masaBerlaku = _masaBerlaku;

        emit LicenseUpdated(_wallet);
    }

    // 🔍 Cek lisensi
    function cekLisensi(address _wallet)
        public
        view
        returns (
            string memory nama,
            string memory bidang,
            uint256 tanggalTerbit,
            uint256 masaBerlaku,
            bool aktif,
            bool valid
        )
    {
        License memory l = licenses[_wallet];

        require(l.exists, "Lisensi tidak ditemukan");

        // ✅ cek expired
        bool masihBerlaku = block.timestamp <= (l.tanggalTerbit + l.masaBerlaku);

        bool statusValid = l.aktif && masihBerlaku;

        return (
            l.nama,
            l.bidang,
            l.tanggalTerbit,
            l.masaBerlaku,
            l.aktif,
            statusValid
        );
    }
}